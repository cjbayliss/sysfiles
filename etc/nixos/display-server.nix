{
  config,
  lib,
  pkgs,
  ...
}: {
  services.xserver = {
    enable = true;
    layout = "us";
    exportConfiguration = true;

    wacom.enable = true;
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };

    windowManager.qtile.enable = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };

    # needed to prevent NixOS from installing a display manager
    displayManager.sx.enable = true;
  };

  services.picom.enable = true;
}
