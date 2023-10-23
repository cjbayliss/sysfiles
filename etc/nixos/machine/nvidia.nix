{ config, lib, pkgs, ... }:
{
  hardware.opengl = {
    enable = true;

    extraPackages = [ pkgs.vaapiVdpau ];

    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = false;

    open = false; # my GTX 1070 is unsupported by this driver :'(
    # package = config.boot.kernelPackages.nvidiaPackages.beta;

    powerManagement.enable = false;
    powerManagement.finegrained = false;

    forceFullCompositionPipeline = true;
  };
}
