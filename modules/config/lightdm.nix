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
  options.nixathena.lightdm.enable = lib.mkEnableOption "LightDM";

  config = lib.mkIf config.nixathena.lightdm.enable {
    # The Debathena greeter may just show a black screen if AFS hangs
    # Let's just hope that never happens...
    services.xserver.displayManager.lightdm = {
      enable = true;
      greeter = lib.mkDefault {
        package = athena-pkgs.lightdm-debathena-greeter.xgreeters;
        name = "debathena-lightdm-greeter";
      };
      greeters.gtk.enable = false;
    };
  };
}
