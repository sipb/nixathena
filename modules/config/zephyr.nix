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
  options.nixathena.zephyr.enable = lib.mkEnableOption "Zephyr";

  config = lib.mkIf config.nixathena.zephyr.enable {
    # From https://github.com/andersk/nixathena/blob/main/modules/zephyr-client.nix
    networking.firewall.allowedUDPPorts = [ 2104 ];
    systemd.services.athena-zhm = {
      description = "Zephyr host manager";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getBin athena-pkgs.zephyr}/bin/zhm -n -f";
      };
    };
  };
}
