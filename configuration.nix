# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ==========================================
  # Bootloader & Splash Screen
  # ==========================================
  boot = {
    # Kernel & Drivers
    kernelPackages = pkgs.linuxPackages_latest;

    # Clean boot output for Plymouth
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

	# Minimal NixOS logo splash
        plymouth = {
        enable = true;
		theme = "bgrt";
         };
    # Systemd-boot & Generation Settings
    loader = {
      efi.canTouchEfiVariables = true;
      
      systemd-boot = {
        enable = true;
        
        # Native display resolution (no pixelated text)
        consoleMode = "max";
        
        # Keep generation list tidy (caps menu to 10 entries)
        configurationLimit = 10;
        
        # Sort so newest generations stay on top
        sortKey = "nixos";
      };
    };

  };

  # ==========================================
  # Network & System
  # ==========================================
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

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

  # ==========================================
  # Desktop Environment & Display Manager
  # ==========================================
  services.xserver.enable = false;
  services.displayManager.sddm.enable = false;
  services.desktopManager.plasma6.enable = false;

  # Sway Window Manager
	programs.mango.enable = true;

 	 environment.sessionVariables = {
    	WLR_NO_HARDWARE_CURSORS = "1";
    	NVD_BACKEND = "direct";
    	MOZ_ENABLE_WAYLAND = "1";
    	XDG_SESSION_TYPE = "wayland";
    	XDG_CURRENT_DESKTOP = "mango";
  	};
  programs.waybar.enable = true;
  programs.zsh.enable = true;

  # Auto-start Sway on tty1 login
	programs.zsh.loginShellInit = ''
	      if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
	        if [ "$(tty)" = "/dev/tty1" ]; then
	          exec jay run-privileged
	        elif [ "$(tty)" = "/dev/tty2" ]; then
	          exec mango
	        fi
	      fi
	    '';
  # XDG Portals
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    wlr.settings = {
      screencast = {
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      };
    };
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.sway.default = lib.mkForce [ "wlr" "gtk" ];
  };

  # ==========================================
  # Nvidia Driver Configuration
  # ==========================================
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

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ==========================================
  # Audio, Printing & Hardware
  # ==========================================
  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # ==========================================
  # User Configuration & Packages
  # ==========================================
  users.users."xv" = {
    isNormalUser = true;
    description = "xv";
    extraGroups = [ "networkmanager" "wheel" "video" ]; 
    shell = pkgs.zsh;
    packages = with pkgs; [
      fuzzel
      swaynotificationcenter
      ghostty
      fastfetch
      wl-clipboard
      polkit_gnome
      micro
      vesktop 
      mew
      jq
      spotify
      git
      prismlauncher
      
      grim
      slurp
      swappy
      awww

      brightnessctl
      pulseaudio 
      playerctl
    ];
  };

  # Polkit Agent for Sway
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

  programs.firefox.enable = true;

  # ==========================================
  # Applications & Environment
  # ==========================================
  programs.obs-studio = {
    enable = true;
    package = ( pkgs.obs-studio.override { cudaSupport = true; } );
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.variables = {
    EDITOR = "micro";
    VISUAL = "micro";
    TERMINAL = "ghostty";
    LIBVA_DRIVER_NAME = "nvidia";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    font-awesome
  ];

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  services.gvfs.enable = true; 
  services.tumbler.enable = true; 

  # ==========================================
  # Nix System Configuration
  # ==========================================
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "26.05"; 
}
