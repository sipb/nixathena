{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nixathena.pkgsync;
  pkgsync = pkgs.writers.writeFishBin "pkgsync" ../../pkgs/pkgsync.fish;
in
{
  options.nixathena.pkgsync.enable = lib.mkEnableOption "pkgsync, a nix profile convenience wrapper" // {
    default = config.nixathena.workstation;
    defaultText = lib.literalExpression "config.nixathena.workstation";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgsync ];

    systemd.user.services.pkgsync = {
      wantedBy = [ "default.target" ];
      path = [ pkgs.nix ];
      serviceConfig.ExecStart = "${pkgsync}/bin/pkgsync";
    };
  };
}
