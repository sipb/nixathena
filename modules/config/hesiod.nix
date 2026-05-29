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
  };
}
