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
  options.nixathena.lightdm.enable = lib.mkEnableOption "LightDM" // {
    default = config.nixathena.workstation;
    defaultText = lib.literalExpression "config.nixathena.workstation";
  };

  config = lib.mkIf config.nixathena.lightdm.enable {
    # The Debathena greeter may show a black screen if AFS hangs, which often happens when you're using MIT Wi-Fi instead of Ethernet
    # Let's just hope that never happens on the workstations...
    # Anyways you can switch to a TTY if that happens
    services.xserver.displayManager = {
      lightdm = {
        enable = true;
        greeter = {
          package = athena-pkgs.lightdm-debathena-greeter.xgreeters;
          name = "debathena-lightdm-greeter";
        };
        greeters.gtk.enable = false;
      };
    };
  };
}
