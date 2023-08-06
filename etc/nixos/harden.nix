{ config, pkgs, lib, ... }:

{
  # import the activly maintained hardend profile, you can find it here:
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/hardened.nix
  imports = [ <nixpkgs/nixos/modules/profiles/hardened.nix> ];

  # restore memoryAllocator to default or many programs crash:
  environment.memoryAllocator.provider = "libc";
  # IMPORTANT: don't block modules from being loaded
  security.lockKernelModules = false;

  # don't use the 'hardened' kernel
  boot.kernelPackages = pkgs.linuxPackages;

  # don't disable multi-threading (yeah, ik multi-threading has risks)
  #security.allowSimultaneousMultithreading = true;

  # TODO: finish the job cjb!
  # harden systemd services. See: systemd-analyze security start by
  # disabling any service and deps that we don't need:
  system.nssModules = lib.mkForce [ ];
  services.nscd.enable = false;
  users.ldap.nsswitch = false;

  systemd.services.dbus.serviceConfig = {
    IPAddressDeny = "any";
    LockPersonality = "yes";
    NoNewPrivileges = "yes";
    ProtectControlGroups = "yes";
    ProtectKernelModules = "yes";
    ProtectKernelTunables = "yes";
    RestrictRealtime = "yes";
    UMask = "0077";
  };

  # hardening this service is hard due to agetty spawning everything for the
  # user environment. NOTE: ping(8) does not work with this config
  systemd.services."getty@".serviceConfig = {
    IPAddressDeny = "any";
    LockPersonality = "yes";
    NoNewPrivileges = "yes";
    ProtectControlGroups = "yes";
    ProtectKernelModules = "yes";
    ProtectKernelTunables = "yes";
    RestrictRealtime = "yes";
    UMask = "0077";
  };

  systemd.services.podman.serviceConfig = {
    CapabilityBoundingSet = "";
    IPAddressDeny = "any";
    LockPersonality = "yes";
    MemoryDenyWriteExecute = "yes";
    NoNewPrivileges = "yes";
    PrivateMounts = "yes";
    PrivateNetwork = "yes";
    PrivateTmp = "yes";
    PrivateUsers = "yes";
    ProtectControlGroups = "yes";
    ProtectHome = "yes";
    ProtectKernelModules = "yes";
    ProtectKernelTunables = "yes";
    ProtectSystem = "strict";
    RestrictRealtime = "yes";
    UMask = "0077";
  };

  # the nixos nvidia module enables apcid... on a systemd system 🧐
  services.acpid.enable = lib.mkForce false;

  security.apparmor.enable = true;
  services.dbus.apparmor = "enabled";
}
