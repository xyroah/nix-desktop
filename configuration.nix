{ config, pkgs, lib, mcsrPkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # boot stuff 
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    kernelModules = [ "v4l2loopback" ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Virtual Camera" exclusive_caps=1
    '';
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "vt.global_cursor_default=0"
    ];
    plymouth = {
      enable = true;
      theme = "bgrt";
    };
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = false;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
        extraEntries = ''
          menuentry "NixOS (500GB)" {
            search --no-floppy --fs-uuid --set=root C26C-1D24
            chainloader /EFI/systemd/systemd-bootx64.efi
          }
        '';
      };
    };
  };
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

  # --- Network & Locale ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  #  Environment Variables 
  environment.sessionVariables = {
    NVD_BACKEND = "direct";
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORMTHEME = "gtk3";
  };

  environment.variables = {
    EDITOR = "micro";
    VISUAL = "micro";
    TERMINAL = "ghostty";
    LIBVA_DRIVER_NAME = "nvidia";
  };

  #desktop stuff 
  programs.xwayland.enable = true;
  programs.zsh.enable = true;
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 3";
    flake = "/home/xv/.dotfiles";
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd 'jay run'";
        user = "greeter";
      };
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    wlr.settings = {
      screencast = {
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      };
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      (pkgs.writeTextDir "share/xdg-desktop-portal/portals/jay.portal" ''
        [portal]
        DBusName=org.freedesktop.impl.portal.desktop.jay
        Interfaces=org.freedesktop.impl.portal.ScreenCast;org.freedesktop.impl.portal.RemoteDesktop;
      '')
    ];
    config.jay = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "jay" ];
      "org.freedesktop.impl.portal.RemoteDesktop" = [ "jay" ];
      "org.freedesktop.impl.portal.Inhibit" = [ "none" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };
  };

  # hardware
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.xkb.layout = "us";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  # --- audio & stuff ---
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.printing.enable = true;
  services.blueman.enable = true;
  services.ratbagd.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.logitech.wireless.enable = true;

  virtualisation.docker.enable = true;
  programs.dconf.enable = true;

  # user
    users.users."xv" = {
    isNormalUser = true;
    description = "xv";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      fuzzel
      swaynotificationcenter
      ghostty
      fastfetch
      wl-clipboard
      polkit_gnome
      vesktop
      mew
      jq
      spotify
      git
      (prismlauncher.override {
        additionalLibs = [ 
        pkgs.jemalloc
        pkgs.libxkbcommon
         ];
        jdks = [
          mcsrPkgs.graalvm-21
          pkgs.temurin-bin-21
          pkgs.temurin-bin-25
        ];
      })
      grim
      slurp
      swappy
      awww
      brightnessctl
      pulseaudio
      playerctl
    ];
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # applications
  programs.java = {
    enable = true;
    package = pkgs.temurin-bin-21;
  };

  programs.firefox.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.gamemode.enable = true;

  programs.obs-studio = {
    enable = true;
    package = (pkgs.obs-studio.override { cudaSupport = true; });
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
    ];
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  programs.xfconf.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    font-awesome
  ];

  # shit
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-40.10.5"
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "26.05";
}
