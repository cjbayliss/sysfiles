{ config, lib, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    layout = "us";
    exportConfiguration = true;

    wacom.enable = true;
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      # haskellPackages = unstable.haskellPackages;
    };

    displayManager.sx.enable = true;
  };

  services.picom.enable = true;
}
