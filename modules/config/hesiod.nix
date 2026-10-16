{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nixathena.hesiod;
  athena-pkgs = pkgs.extend (import ../../pkgs);
in
{
  options.nixathena.hesiod = {
    enable = lib.mkEnableOption "Hesiod client library" // {
      default = config.nixathena.workstation;
      defaultText = lib.literalExpression "config.nixathena.workstation";
    };

    lhs = lib.mkOption {
      description = "Domain prefix used for Hesiod queries.";
      type = lib.types.str;
      default = ".ns";
    };

    rhs = lib.mkOption {
      description = "Default domain used for Hesiod queries.";
      type = lib.types.str;
      default = ".athena.mit.edu";
    };

    classes = lib.mkOption {
      description = "Class search order used for Hesiod queries.";
      type = lib.types.str;
      default = "IN";
    };

    nsswitch = lib.mkOption {
      description = "Whether to configure Name Service Switch to use Hesiod. This makes Linux aware of Athena users.";
      type = lib.types.bool;
      default = true;
    };
  };

  # See https://nullroute.lt/~grawity/hesiod.html for some background info about Hesiod
  config = lib.mkIf cfg.enable {
    environment.etc."hesiod.conf".text = ''
      lhs=${cfg.lhs}
      rhs=${cfg.rhs}
      classes=${cfg.classes}
    '';

    environment.systemPackages = [ athena-pkgs.hesiod ];

    # Hesiod comes built-in to glibc but apparently it's deprecated and might get removed in the future 😥
    system.nssDatabases = lib.mkIf cfg.nsswitch {
      passwd = [ "hesiod" ];
      group = [ "hesiod" ];
    };

    # So...
    # There's a very convoluted bug where occasionally systemd-logind will get into a weird state
    # And throw this error when logging in, but only for Hesiod users:
    #  Varlink call io.systemd.Login.CreateSession failed: io.systemd.System
    # This breaks systemd --user for instance
    # When logind tries to add a new session, it uses NSS to get info about the user
    # NixOS is weird and unlike other distros, it uses the nsncd daemon to handle NSS
    # (nsncd was created by Two Sigma, yes, that quant company; I have no idea why)
    # This is because traditional distros use glibc to resolve users (or SSSD for fancy enterprises),
    # which loads NSS modules (like nss_hesiod) using dlopen()
    # But this approach doesn't work on NixOS where apps can have different glibc versions
    # Instead, on NixOS the glibc runs an nscd client which proxies requests to nsncd (a replacement for the default nscd which is super buggy)
    # Well... turns out the nscd client is also quite buggy and weird
    # So normally, logind's glibc will tell nsncd to make a Hesiod DNS request, yay
    # However, glibc nscd client has a five second timeout[^1]
    # If it fails, it sets __nss_not_use_nscd_passwd[^2] which makes the client stop using nsncd for 100 attempts[^3]
    # Instead, the client will load the nss_hesiod module itself and try to make the Hesiod request
    # However, logind is sandboxed by systemd with "RestrictAddressFamilies=AF_UNIX AF_NETLINK" so it can't open a UDP socket to make that request
    # Since __nss_not_use_nscd_passwd is now set for the logind process, it takes 100 more login attempts before it gets un-borked
    # The "systemd-brained" solution for this would be to use systemd-userdbd,
    # which adds yet another daemon and spawns worker processes that run the nscd clients so it can't screw up logind
    # However the simpler solution is just to weaken the sandbox for logind slightly and allow it to make DNS requests
    # [^1]: https://sourceware.org/git/?p=glibc.git;a=blob;f=nscd/nscd_helper.c;h=6319fde6f2d17183221289b838041aea94433d6b;hb=HEAD#l543
    # [^2]: https://sourceware.org/git/?p=glibc.git;a=blob;f=nscd/nscd_getpw_r.c;h=f19b7a271c6c4058231c62249268e2c520444f5e;hb=HEAD#l127
    # [^3]: https://sourceware.org/git/?p=glibc.git;a=blob;f=nscd/nscd_proto.h;h=917324aebd3f9633355d9023c048308ebf77117f;hb=HEAD#l26
    systemd.services.systemd-logind.serviceConfig = {
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
      # By default this is IPAddressDeny=any
      IPAddressDeny = "";
    };
  };
}
