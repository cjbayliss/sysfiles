{
  config,
  pkgs,
  ...
}:
with pkgs; let
  iosevka-fixed = callPackage ./packages/iosevka-fixed {};
in {
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
    experimental-features = ["nix-command" "flakes"];
    use-xdg-base-directories = true;
  };

  fileSystems."/home/cjb/.local/cache" = {
    device = "none";
    fsType = "tmpfs";
    options = ["size=2G" "mode=777"];
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
    extraConfig = ''
      DNS=9.9.9.9
      DNSOverTLS=yes
    '';
    fallbackDns = ["149.112.112.112"];
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
    extraGroups = ["audio" "wheel" "video"];
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    # tools
    dconf
    efibootmgr
    helix
    libimobiledevice
    logiops
    xdg-desktop-portal-gtk
  ];

  services.usbmuxd.enable = true;

  xdg.portal.config.common.default = "*";

  # Epomaker EP64 config
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["3151:4011"];
        settings = {
          main = {
            capslock = "esc";
            leftmeta = "layer(alt)";
            leftalt = "layer(meta)";
            escape = "`";
          };

          # since I remap alt to meta, C-A-f<NUMBER> doesn't work on this
          # keyboard, so map C-A-<NUMBER> to C-A-f<NUMBER>
          "control+alt" = {
            "1" = "C-A-f1";
            "2" = "C-A-f2";
            "3" = "C-A-f3";
            "4" = "C-A-f4";
            "5" = "C-A-f5";
            "6" = "C-A-f6";
          };
        };
      };
    };
  };

  # for Logitech M720 mouse
  systemd.services.logid = {
    enable = true;
    description = "Logitech Configuration Daemon";

    unitConfig = {
      After = ["multi-user.target"];
      Wants = ["multi-user.target"];
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

    wantedBy = ["graphical.target"];
  };

  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

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
      domain = "*";
      item = "nofile";
      type = "-";
      value = "524288";
    }
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
      value = "524288";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "hard";
      value = "524288";
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
    enableDefaultPackages = false;
    packages = with pkgs; [
      iosevka-fixed
      ipafont
      liberation_ttf
      nanum
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
    ];

    fontconfig = {
      hinting.style = "full";
      useEmbeddedBitmaps = true;

      defaultFonts.emoji = ["Noto Color Emoji"];
      defaultFonts.monospace = [
        "Iosevka Fixed"
        "Noto Color Emoji"
        "NanumGothicCoding"
        "D2Coding"
        "Noto Mono CJK HK"
        "Noto Mono CJK JP"
        "Noto Mono CJK KR"
        "Noto Mono CJK SC"
        "Noto Mono CJK TC"
        "Noto Mono"
      ];
      defaultFonts.sansSerif = [
        "Liberation Sans"
        "Noto Color Emoji"
        "IPAGothic"
        "NanumGothic"
        "Noto Sans CJK HK"
        "Noto Sans CJK JP"
        "Noto Sans CJK KR"
        "Noto Sans CJK SC"
        "Noto Sans CJK TC"
        "Noto Sans"
      ];
      defaultFonts.serif = [
        "Liberation Serif"
        "Noto Color Emoji"
        "IPAMincho"
        "NanumMyeongjo"
        "Noto Serif CJK HK"
        "Noto Serif CJK JP"
        "Noto Serif CJK KR"
        "Noto Serif CJK SC"
        "Noto Serif CJK TC"
        "Noto Serif"
      ];

      localConf = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <alias binding="strong">
            <family>monospace</family>
            <prefer>
              <family>Iosevka Fixed</family>
              <family>Noto Color Emoji</family>
            </prefer>
          </alias>

          <alias binding="strong">
            <family>sans-serif</family>
            <prefer>
              <family>Liberation Sans</family>
              <family>Noto Color Emoji</family>
            </prefer>
          </alias>

          <alias binding="strong">
            <family>serif</family>
            <prefer>
              <family>Liberation Serif</family>
              <family>Noto Color Emoji</family>
            </prefer>
          </alias>

          <alias binding="strong">
            <family>Iosevka</family>
            <prefer>
              <family>Iosevka Fixed</family>
            </prefer>
          </alias>

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

  environment.variables = {
    HISTFILE = "$XDG_DATA_HOME/history";
  };

  programs.bash = {
    # better history
    shellInit = ''
      shopt -s histappend
      HISTCONTROL=ignoreboth
      HISTSIZE=-1
      HISTFILESIZE=-1
      HISTFILE="$XDG_DATA_HOME/bash-history"
    '';

    # better completion
    interactiveShellInit = ''
      bind "set menu-complete-display-prefix on"
      bind "set show-all-if-ambiguous on"
      bind "set completion-query-items 0"
      bind "TAB:menu-complete"
      bind "\"\e[Z\": menu-complete-backward"
    '';

    promptInit = ''
      PS1="\[\e[0m\]''\${HOSTNAME:=$ hostname} \[\e[96m\]\$(pwd | sed 's/\/home\/'$USER'/~/')\[\e[0m\]\[\e[95m\]\$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/')\[\e[35m\]\$(git status --porcelain 2>/dev/null | cut -c1,2 | sort -u | tr -d ' \n' | sed 's/^/ /')\[\e[0m\] » "
    '';
  };
}
