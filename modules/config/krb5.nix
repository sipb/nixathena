{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nixathena.krb5.enable = lib.mkEnableOption "Kerberos for ATHENA.MIT.EDU" // {
    default = true;
  };
  config = lib.mkIf config.nixathena.krb5.enable {
    security.krb5 = {
      enable = true;
      settings = {
        libdefaults = {
          default_realm = "ATHENA.MIT.EDU";
        };
        domain_realm = {
          ".exchange.mit.edu" = "EXCHANGE.MIT.EDU";
          "exchange.mit.edu" = "EXCHANGE.MIT.EDU";
          ".mit.edu" = "ATHENA.MIT.EDU";
          "mit.edu" = "ATHENA.MIT.EDU";
          ".win.mit.edu" = "WIN.MIT.EDU";
          "win.mit.edu" = "WIN.MIT.EDU";
          ".csail.mit.edu" = "CSAIL.MIT.EDU";
          "csail.mit.edu" = "CSAIL.MIT.EDU";
          ".media.mit.edu" = "MEDIA-LAB.MIT.EDU";
          "media.mit.edu" = "MEDIA-LAB.MIT.EDU";
          ".whoi.edu" = "ATHENA.MIT.EDU";
          "whoi.edu" = "ATHENA.MIT.EDU";
        };
        # This is what the dialups use
        realms."ATHENA.MIT.EDU" = {
          admin_server = "kerberos.mit.edu";
          master_kdc = "kerberos.mit.edu";
          default_domain = "mit.edu";
          kdc = [
            "kerberos.mit.edu:88"
            "kerberos-1.mit.edu:88"
            "kerberos-2.mit.edu:88"
            "kerberos-3.mit.edu:88"
          ];
        };
      };
    };
    # Only allow Kerberos login on workstations
    security.pam.krb5.enable = config.nixathena.workstation;
    programs.ssh.package = pkgs.opensshWithKerberos;
    services.openssh = {
      # You also need to get a keytab for the SSH server!
      # https://sipb.mit.edu/previously/doc/kerberized-server/
      # https://www.kevindiaz.dev/blog/configuring-openssh-to-use-kerberos-authentication.html
      package = pkgs.opensshWithKerberos;
      extraConfig = ''
        GSSAPIAuthentication yes
        GSSAPICleanupCredentials yes
      '';
    };
  };
}
