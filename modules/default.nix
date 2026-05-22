{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.nixathena;
  athena-pkgs = pkgs.extend (import ../pkgs);
  defaultPackages = [
    athena-pkgs.discuss
    athena-pkgs.remctl
    athena-pkgs.moira
    athena-pkgs.zephyr
    athena-pkgs.python3Packages.locker-support
    athena-pkgs.barnowl
    athena-pkgs.athrun
  ];
in
{
  imports = [
    ./config/hesiod.nix
    ./config/krb5.nix
    ./config/ldap.nix
    ./config/lightdm.nix
    ./config/pam-afs-session.nix
    ./config/zephyr.nix
    ./services/pyhesiodfs.nix
  ];

  options.nixathena = {
    workstation = lib.mkOption {
      description = "Whether to configure the computer as an Athena workstation and allow any Athena user to log in.";
      default = false;
      type = lib.types.bool;
    };
    packages = lib.mkOption {
      description = "list of packages to install";
      default = defaultPackages;
      type = lib.types.listOf lib.types.package;
    };
  };

  config = lib.mkMerge [
    {
      environment.systemPackages = cfg.packages;
      services.pyhesiodfs.enable = lib.mkDefault true;
      services.openafsClient = {
        enable = lib.mkDefault true;
        cellName = lib.mkDefault "athena.mit.edu";
      };
      nixathena.krb5.enable = lib.mkDefault true;
    }
    (lib.mkIf cfg.workstation {
      nixathena = {
        hesiod.enable = lib.mkDefault true;
        ldap.enable = lib.mkDefault true;
        lightdm.enable = lib.mkDefault true;
        pam-afs-session.enable = lib.mkDefault true; # Get AFS token on login
        zephyr.enable = lib.mkDefault true;
      };
      # TODO: Move some of this stuff into ./config
      # Athena env vars
      # This is what the dialups use
      environment.variables = {
        ATHENA_SYS = "amd64_ubuntu2204";
        ATHENA_SYS_COMPAT = "i386_ubuntu2204:amd64_ubuntu2004:i386_ubuntu2004:amd64_deb100:i386_deb100:amd64_ubuntu1804:i386_ubuntu1804:amd64_deb90:i386_deb90:amd64_ubuntu1604:i386_ubuntu1604:amd64_deb80:i386_deb80:amd64_ubuntu1404:i386_ubuntu1404:amd64_deb70:i386_deb70:amd64_ubuntu1204:i386_ubuntu1204:amd64_ubuntu1004:i386_ubuntu1004:amd64_ubuntu904:i386_ubuntu904:amd64_deb50:i386_deb50:amd64_ubuntu804:i386_ubuntu804:amd64_deb40:i386_deb40:i386_rhel4";
        HOSTTYPE = "linux";
      };
      programs = {
        # `add` command
        bash.interactiveShellInit = ''
          add ()
          {
            eval "$( attach -Padd -b $add_flags "$@" )"
          }
        '';
        fish.interactiveShellInit = ''
          function add
            eval (attach -Padd -b $add_flags $argv)
          end
        '';
        # For running dynamically linked stufff
        nix-ld.enable = true;
      };
      # This creates /bin/* for better compatibility with Athena stuff
      services.envfs = {
        enable = true;
        # We need special handling for /bin/bash because envfs doesn't work with sshd for some reason
        # Some people have the shell /bin/athena/bash for some reason??
        extraFallbackPathCommands = ''
          mkdir $out/athena
          ln -s ${pkgs.bash}/bin/bash $out/bash
          ln -s ${pkgs.bash}/bin/bash $out/athena/bash
        '';
      };
    })
  ];
}
