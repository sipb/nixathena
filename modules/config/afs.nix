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
  options.nixathena.afs = {
    enable = lib.mkEnableOption "AFS" // {
      default = config.nixathena.enable;
      defaultText = true;
    };
    kafs = lib.mkEnableOption "kAFS instead of OpenAFS";
  };
  config = lib.mkIf config.nixathena.afs.enable {
    services.openafsClient = lib.mkIf (!config.nixathena.afs.kafs) {
      enable = lib.mkDefault true;
      cellName = lib.mkDefault "athena.mit.edu";
    };
    environment.systemPackages = lib.mkIf config.nixathena.afs.kafs [ athena-pkgs.kafs ];
    systemd.packages = lib.mkIf config.nixathena.afs.kafs [ athena-pkgs.kafs ];
    systemd.units."afs.mount".wantedBy = [ "remote-fs.target" ];
  };
}
