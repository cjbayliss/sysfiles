{ config, pkgs, lib, ... }:

{
  imports = [
    <nixos-hardware/common/gpu/nvidia>
    <nixos-hardware/common/cpu/intel>
    <nixos-hardware/common/pc/hdd>
  ];

  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
  };
  boot.loader.timeout = 2;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelModules = [ "wacom" "acpi-call" "nvidia" ];
  boot.kernelParams = [ "threadirqs" "quiet" ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  boot.tmp.useTmpfs = true;

  # for low latency audio
  boot.postBootCommands = ''
    echo 2048 > /sys/class/rtc/rtc0/max_user_freq
    echo 2048 > /proc/sys/dev/hpet/max-user-freq
    ${pkgs.pciutils}/bin/setpci -v -d *:* latency_timer=b0 >/dev/null
    ${pkgs.pciutils}/bin/setpci -v -s 00:1b.0 latency_timer=ff >/dev/null
  '';

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "microcodeIntel"
      "nvidia-settings"
      "nvidia-x11"
      "steam"
      "steam-original"
      "steam-run"
      "steam-runtime"
    ];

  networking = {
    hostId = "d9f87861";
    hostName = "astroloma";

    enableIPv6 = false;
    interfaces.eno1.useDHCP = true;
    interfaces.wlp5s0.useDHCP = true;
    wireless.interfaces = [ "wlp5s0" ];
    wireless.enable = true;

    resolvconf.enable = lib.mkDefault false;
    dhcpcd.extraConfig = "nohook resolv.conf";
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    screenSection = ''
      Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      Option         "AllowIndirectGLXProtocol" "off"
      Option         "TripleBuffer" "on"
    '';
  };

  hardware.enableRedistributableFirmware = true;

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.prime.offload.enable = false;

  programs.steam.enable = true;

  system.stateVersion = "23.05";
}