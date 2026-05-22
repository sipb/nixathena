{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nixathena.ldap.enable = lib.mkEnableOption "LDAP for MIT";
  config = lib.mkIf config.nixathena.ldap.enable {
    environment = {
        systemPackages = [ pkgs.openldap ];
        # This is what the dialups use
        # nixpkgs has users.ldap for generating this file but it also configures a bunch of other unnecessary stuff, so just write the file outselves
        etc."ldap.conf".text = ''
          BASE    dc=mit, dc=edu
          URI     ldap://ldap-too.mit.edu
          TLS_CACERT   /etc/ssl/certs/ca-certificates.crt
        '';
      };
  };
}
