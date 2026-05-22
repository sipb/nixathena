{
  config,
  lib,
  pkgs,
  ...
}:

let
  athena-pkgs = pkgs.extend (import ../../pkgs);
in
{
  options.nixathena.pam-afs-session.enable = lib.mkEnableOption "pam-afs-session";

  config = lib.mkIf config.nixathena.pam-afs-session.enable {
    # The Nix PAM config syntax is badly documented so see https://github.com/NixOS/nixpkgs/pull/255547
    security.pam.services =
      let
        serviceCfg = service: {
          rules = {
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
      in
      lib.flip lib.genAttrs serviceCfg [
        "login"
        "sshd"
      ];
  };
}
