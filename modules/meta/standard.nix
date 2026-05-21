{
  lib,
  pkgs,
  config,
  options,
  ...
}:

let
  cfg = config.nixathena.meta.standard;
  athena-pkgs = pkgs.extend (import ../../pkgs);
  defaultPackages = [
    athena-pkgs.discuss
    athena-pkgs.remctl
    athena-pkgs.moira
  ];
in
{
  imports = [
    ../config/krb5.nix
    ../services/pyhesiodfs.nix
  ];

  options.nixathena.meta.standard = (
    let
      mkOption = lib.mkOption;
      mkEnableOption = lib.mkEnableOption;
      types = lib.types;
    in
    {
      enable = mkEnableOption "Nixathena standard";
      packages = mkOption {
        description = "list of packages to install";
        default = defaultPackages;
        type = types.listOf types.package;
      };
    }
  );

  config = lib.mkIf cfg.enable {
    environment.systemPackages = cfg.packages;
    services.pyhesiodfs.enable = lib.mkDefault true;
    services.openafsClient = {
      enable = lib.mkDefault true;
      cellName = lib.mkDefault "athena.mit.edu";
    };
    nixathena.config.krb5.enable = lib.mkDefault true;
    # Make Linux aware of Kerberos users
    system.nssDatabases.passwd = [ "hesiod" ];
    system.nssDatabases.group = [ "hesiod" ];
    environment.etc."hesiod.conf".text = ''
      lhs=.ns
      rhs=.athena.mit.edu
    '';
    # Get AFS token on login
    # The Nix PAM config syntax is badly documented so see https://github.com/NixOS/nixpkgs/pull/255547
    security.pam.services.login.rules = {
      auth.afs = {
        control = "optional";
        modulePath = "${athena-pkgs.pam-afs-session}/lib/security/pam_afs_session.so";
        order = 20000;
      };
      session.afs = {
        control = "required";
        modulePath = "${athena-pkgs.pam-afs-session}/lib/security/pam_afs_session.so";
        order = 20000;
      };
    };
  };
}
