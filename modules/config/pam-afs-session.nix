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
  options.nixathena.pam-afs-session.enable = lib.mkEnableOption "pam-afs-session" // {
    default = config.nixathena.workstation;
    defaultText = lib.literalExpression "config.nixathena.workstation";
  };

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
              # THIS IS REALLY GROSS AND BRITTLE
              # Put it right after pam_krb5.so to try to avoid race conditions
              # My theory is that this races with systemd, sometimes causing the error "Varlink call io.systemd.Login.CreateSession failed: io.systemd.System"
              # Maybe we should add some amount of sleep in between?
              order = 11900;
              # Ugh... so systemd --user and AFS tokens don't play well together
              # https://www.mail-archive.com/openafs-info@openafs.org/msg40596.html
              # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=846377
              # https://docs.google.com/document/d/1P27fP1uj-C8QdxDKMKtI-Qh00c5_9zJa4YHjnpB6ODM/pub
              # https://github.com/systemd/systemd/issues/7261
              # This hacky line disables AFS PAGs for local logins at the expense of security
              settings.nopag = service == "login";
            };
          };
        };
      in
      lib.flip lib.genAttrs serviceCfg [
        "login"
        "sshd"
      ];
    # Better solution for the systemd --user and AFS problem:
    # https://www.mail-archive.com/openafs-info@openafs.org/msg41345.html
    # There's no great workaround because all the parties involved just point fingers and blame each other
    # Also: https://shorts.j4m3s.eu/posts/nix-systemd-override-execstart/
    # Unfortunately, it doesn't work on NixOS and I have no idea how to debug it weeee
    # So we'll just nopag for now and hope for the best
    # systemd.services."user@".serviceConfig.ExecStart = [ ""
    #   (pkgs.writeShellScript "aklog-before-systemd-user" ''
    #     [[ -z "$UID" || "$UID" -lt 1000 ]] && exec ${pkgs.systemd}/lib/systemd/systemd --user
    #     echo EEEEEEEEEEEEEEEEE
    #     export KRB5CCNAME="KEYRING:persistent:$UID"
    #     ${pkgs.krb5}/bin/klist -s && echo AAAAAAAAAA
    #     ${pkgs.krb5}/bin/klist -s && ${pkgs.openafs}/bin/aklog
    #     exec ${pkgs.systemd}/lib/systemd/systemd --user
    #   '')
    # ];
    # Tips for debugging the Nixathena login process:
    # Just don't do it; it's bad for your mental health
    # But if you do, just remember that's it's highly nondeterministic with race conditions everywhere
  };
}
