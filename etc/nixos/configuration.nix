{ config, pkgs, ... }:

{
  imports = [
    # hardware
    ./hardware-configuration.nix
    ./machine/astroloma.nix
    # display server config
    ./display-server.nix
    # harden the system
    ./harden.nix
  ];

  nix.settings = {
    auto-optimise-store = true;
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
    extraConfig = ''
      DNS=9.9.9.9
      DNSOverTLS=yes
    '';
    fallbackDns = [ "149.112.112.112" ];
  };

  environment.etc."issue".enable = false;

  time.timeZone = "Australia/Melbourne";

  i18n.defaultLocale = "en_AU.UTF-8";

  console = {
    font = "";
    keyMap = "us";
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  programs.fish.enable = true;
  users.users.cjb = {
    isNormalUser = true;
    extraGroups = [ "audio" "wheel" "video" ];
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    # tools
    dconf
    efibootmgr
    logiops
    xdg-desktop-portal-gtk
  ];

  # for Logitech M720 mouse
  systemd.services.logid = {
    enable = true;
    description = "Logitech Configuration Daemon";

    unitConfig = {
      After = [ "multi-user.target" ];
      Wants = [ "multi-user.target" ];
    };

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.logiops}/bin/logid";
      ExecReload = "/bin/kill -HUP $MAINPID";
      Restart = "on-failure";

      # lockdown the service
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

    wantedBy = [ "graphical.target" ];
  };

  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  sound.enable = true;
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };

  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "99";
    }

    {
      domain = "@audio";
      item = "nofile";
      type = "soft";
      value = "99999";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "hard";
      value = "99999";
    }
  ];

  services.udev.extraRules = ''
    KERNEL=="rtc0", GROUP="audio"
    KERNEL=="hpet", GROUP="audio"
  '';

  programs.ssh.startAgent = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "qt";
  };

  virtualisation = {
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  fonts = {
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "Iosevka" ]; })
      baekmuk-ttf
      inter
      iosevka-bin
      ipafont
      liberation_ttf
      noto-fonts-emoji
      tenderness
    ];
    fontconfig = {
      defaultFonts.emoji = [ "Noto Color Emoji" ];
      defaultFonts.monospace =
        [ "Iosevka Fixed" "IPAGothic" "Baekmuk Gulim" "Noto Color Emoji" ];
      defaultFonts.sansSerif = [
        "Inter"
        "Liberation Sans"
        "IPAGothic"
        "Baekmuk Gulim"
        "Noto Color Emoji"
      ];
      defaultFonts.serif = [
        "Tenderness"
        "Liberation Serif"
        "IPAGothic"
        "Baekmuk Gulim"
        "Noto Color Emoji"
      ];
      useEmbeddedBitmaps = true;

      localConf = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <!-- AFAICT NixOS doesn't provide a way to set hintstyle -->
          <match target="font">
            <edit name="hintstyle" mode="assign">
              <const>hintfull</const>
            </edit>
          </match>

          <!-- ensure Emacs chooses the 'Regular' weight, not the 'Medium' one. -->
          <selectfont>
            <rejectfont>
              <pattern>
                <patelt name="family" >
                  <string>Iosevka Fixed</string>
                </patelt>
                <patelt name="weight" >
                  <const>medium</const>
                </patelt>
              </pattern>
            </rejectfont>
          </selectfont>
        </fontconfig>

      '';
    };
  };

  gtk.iconCache.enable = true;
}
