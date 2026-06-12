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
    ./services/discussd.nix
    ./services/pyhesiodfs.nix
    ./services/remctld.nix
  ];

  options.nixathena = {
    enable = lib.mkEnableOption "Nixathena";
    workstation = lib.mkOption {
      description = ''
        Whether to configure the computer as an Athena workstation and allow any Athena user to log in.

        Note that if you have SSH enabled, then any Athena user will be able to SSH into your computer!
      '';
      default = false;
      type = lib.types.bool;
    };
    packages = lib.mkOption {
      description = "list of packages to install";
      default = defaultPackages;
      type = lib.types.listOf lib.types.package;
    };
  };

  # TODO: Move some of this stuff into ./config
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = cfg.packages;
        services.openafsClient = {
          enable = lib.mkDefault true;
          cellName = lib.mkDefault "athena.mit.edu";
        };
        # `add` command
        programs = {
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
        };
        # Athena env vars
        # This is what the dialups use
        # We set these by default, not just for workstations, because it's used by some software such as `attach`
        # TODO: Set different vars for aarch64 and i686 (although for aarch64, I would be surprised if any lockers had software for it)
        environment.variables = {
          ATHENA_SYS = "amd64_ubuntu2204";
          ATHENA_SYS_COMPAT = "i386_ubuntu2204:amd64_ubuntu2004:i386_ubuntu2004:amd64_deb100:i386_deb100:amd64_ubuntu1804:i386_ubuntu1804:amd64_deb90:i386_deb90:amd64_ubuntu1604:i386_ubuntu1604:amd64_deb80:i386_deb80:amd64_ubuntu1404:i386_ubuntu1404:amd64_deb70:i386_deb70:amd64_ubuntu1204:i386_ubuntu1204:amd64_ubuntu1004:i386_ubuntu1004:amd64_ubuntu904:i386_ubuntu904:amd64_deb50:i386_deb50:amd64_ubuntu804:i386_ubuntu804:amd64_deb40:i386_deb40:i386_rhel4";
          HOSTTYPE = "linux";
        };
      }
      (lib.mkIf cfg.workstation {
        # We need this for Kerberos login
        networking.domain = "mit.edu";
        # For running dynamically linked stufff
        programs.nix-ld.enable = true;
        # This creates /bin/* for better compatibility with Athena stuff
        services.envfs = {
          enable = true;
          # We need special handling for /bin/bash because envfs doesn't work with sshd for some reason
          # Some people have the shell /bin/athena/bash for some reason??
          # I've also seen /bin/athena/tcsh in the wild 🙀️
          extraFallbackPathCommands = ''
            mkdir $out/athena
            ln -s ${pkgs.bash}/bin/bash $out/bash
            ln -s ${pkgs.bash}/bin/bash $out/athena/bash
            ln -s ${pkgs.zsh}/bin/zsh $out/zsh
            ln -s ${pkgs.zsh}/bin/zsh $out/athena/zsh
          '';
        };
        # Allow running AppImages seamlessly
        programs.appimage = {
          enable = true;
          binfmt = true;
        };
        # Simple reimplementation of /usr/athena/lib/init
        # This also gets rid of the "initialization has not been performed" warnings
        # The originals are at https://github.com/mit-athena/dotfiles and https://github.com/mit-athena/dotfiles
        # However, a lot of stuff in there is either broken (ex: quota.debathena) or unnecessary
        # So this super simple reimplementation probably causes less bugs actually
        # Add more lines from the originals if people complain
        # Note that environment.etc.<name>.target only works for stuff in /etc so we have to use a tmpfiles rule instead
        systemd.tmpfiles.rules =
          let
            athena-bashrc = pkgs.writeText "athena-bashrc" ''
              test -f ~/.bash_environment && source ~/.bash_environment
              test -f ~/.bashrc.mine && source ~/.bashrc.mine
            '';
          in
          [
            "f+ /usr/athena/lib/init/bash_login 0644 root root -"
            "L+ /usr/athena/lib/init/bashrc - - - - ${athena-bashrc}"
          ];
      })
    ]
  );
}
