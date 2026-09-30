{ config, pkgs, inputs, ... }:

{
  home.username = "xv";
  home.homeDirectory = "/home/xv";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    waywall
    wayfreeze
    mpv
    swayimg
    google-chrome
    piper
    winboat
    freerdp
    librepods
    losslesscut
    waybar
    btop
    nixd
    obs-cmd
    psmisc
    chatterino7
    pavucontrol
    unzip
    neovim
    gcc
    ripgrep
    fd
    cava
    (pkgs.callPackage ./ninjabrain-bot.nix { })
    inputs.ninjabrain-bot-xwayland.packages.${pkgs.stdenv.hostPlatform.system}.default
    zsh-syntax-highlighting
    zsh-autosuggestions
  ];

  home.pointerCursor = {
    enable = true;
    name = "catppuccin-mocha-dark-cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # gtk
  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-mauve-standard"; 
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        size = "standard";
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
  dconf.enable = true;      
          
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "image/jpeg" = "swayimg.desktop";
      "image/png" = "swayimg.desktop";
      "image/gif" = "swayimg.desktop";
      "image/webp" = "swayimg.desktop";
      "image/svg+xml" = "swayimg.desktop";
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop"; 
      "video/webm" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
    };
  };
    
  xdg.configFile."waywall" = {
    source = ./waywall;
    recursive = true;
  };
  xdg.configFile."waybar".source = ./waybar;  
  xdg.configFile."micro/colorschemes".source = ./micro/colorschemes;
  xdg.configFile."swaylock/config".source = ./swaylock/config;
  home.file.".zshrc".source = ./zshrc;

  xdg.configFile."vesktop-flags.conf".text = ''
    --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer
    --ozone-platform=wayland
  '';

  # micro
  programs.micro = {
    enable = true;
    settings = {
      colorscheme = "catppuccin-mocha-transparent";
      tabstospaces = true;
      tabsize = 2;
      mkparents = true;
      softwrap = true;
      "lsp.server" = "nix=nixd";
      "lsp.formatOnSave" = true;
      "lsp.tabcompletion" = true;
    };
  };

  # jay
  wayland.windowManager.jay = {
    enable = true;
    settings = {
      gfx-api = "Vulkan";
      repeat-rate = { rate = 50; delay = 200; };
      use-hardware-cursor = false;
      focus-follows-mouse = false;
      unstable-mouse-follows-focus = "output"; 
      middle-click-paste = false;
      workspace-display-order = "sorted";
      fallback-output-mode = "focus";
      explicit-sync = true;
      show-titles = false;
      show-bar = false;
      direct-scanout = true;
      render-device = { name = "nvidia"; };
      window-management-key = "Super_L";

      on-graphics-initialized = [
        { type = "exec"; exec = { prog = "dbus-update-activation-environment"; args = [ "--systemd" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP" "XDG_SESSION_TYPE" ]; }; }
        { type = "exec"; exec = { prog = "systemctl"; args = [ "--user" "restart" "xdg-desktop-portal" ]; }; }   
        { type = "exec"; exec = { prog = "waybar"; privileged = true; }; }
        { type = "exec"; exec = { prog = "swaync"; privileged = true; }; }
        { type = "exec"; exec = { prog = "awww-daemon"; privileged = true; }; }
        { type = "exec"; exec = { prog = "zsh"; args = [ "-c" "sleep 1 && awww img ${./assets/image.png}" ]; }; }
        { type = "show-workspace"; name = "1"; output = { name = "Main"; }; move-to-output = true; }
        { type = "show-workspace"; name = "2"; output = { name = "Secondary"; }; move-to-output = true; }
        { type = "exec"; exec = "systemctl --user start polkit-gnome-authentication-agent-1.service"; }
      ];

      theme = {
        border-width = 2;
        container-borders = "full";
        border-color = "#FFFFFF00";
        bar-separator-width = 1;
        separator-color = "#350030";
        bg-color = "#000000";
        focused-title-bg-color = "#350030";
        focused-title-text-color = "#EEEEEE";
        unfocused-title-bg-color = "#000000";
        unfocused-title-text-color = "#999999";
        focused-inactive-title-bg-color = "#250015";
        focused-inactive-title-text-color = "#999999";
        focused-border-color = "#1A1B26";
        workspace-display-order = "sorted";
      };

      drm-devices = [
        { name = "nvidia"; match = { pci-vendor = 4318; pci-model = 11525; }; }
        { name = "intel"; match = { pci-vendor = 32902; pci-model = 42880; }; }
      ];

      inputs = [
        { match = { is-pointer = true; }; accel-profile = "flat"; accel-speed = -0.96; natural-scrolling = false; }
      ];

      outputs = [
        { name = "Main"; match = { connector = "DP-3"; }; x = 1920; y = 0; mode = { width = 1920; height = 1080; refresh-rate = 179.998; }; tearing = { mode = "always"; }; }
        { name = "Secondary"; match = { connector = "DP-4"; }; x = 0; y = 0; mode = { width = 1920; height = 1080; refresh-rate = 179.998; }; tearing = { mode = "always"; }; }
      ];

      shortcuts = {
        logo-Return  = { type = "exec"; exec = "ghostty"; };
        logo-p       = { type = "exec"; exec = "fuzzel"; };
        logo-shift-s = { type = "exec"; exec = { prog = "zsh"; args = [ "-c" "wayfreeze --after-freeze-cmd 'grim -g \"$(slurp)\" - | wl-copy; pkill wayfreeze'" ]; privileged = true; }; };
        logo-shift-m = { type = "exec"; exec = { prog = "zsh"; args = [ "-c" "wayfreeze --after-freeze-cmd 'grim -g \"$(slurp)\" /tmp/swappy.png; pkill wayfreeze; swappy -f /tmp/swappy.png'" ]; privileged = true; }; };
        logo-x       = { type = "exec"; exec = { prog = "zsh"; args = [ "-c" "swaync-client -t -sw" ]; }; };
        
        logo-q             = "close";
        logo-f             = "toggle-fullscreen";
        logo-shift-q       = "quit";
        logo-shift-r       = "reload-config-toml";
        logo-shift-space   = "toggle-floating";
        alt-shift-p        = "toggle-float-pinned";

        XF86AudioRaiseVolume = { type = "exec"; exec = { prog = "wpctl"; args = [ "set-sink-volume" "0" "+5%" ]; }; };
        XF86AudioLowerVolume = { type = "exec"; exec = { prog = "wpctl"; args = [ "set-sink-volume" "0" "-5%" ]; }; };
        XF86AudioMute        = { type = "exec"; exec = { prog = "wpctl"; args = [ "set-sink-mute" "0" "toggle" ]; }; };

        logo-shift-j = { type = "exec"; exec = { prog = "zsh"; args = [ "-c" "obs-cmd recording toggle" ]; }; };
        logo-shift-k = { type = "exec"; exec = { prog = "zsh"; args = [ "-c" "obs-cmd replay save" ]; }; };

        # workspace  
        logo-1 = [ { type = "show-workspace"; name = "1"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-2 = [ { type = "show-workspace"; name = "2"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-3 = [ { type = "show-workspace"; name = "3"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-4 = [ { type = "show-workspace"; name = "4"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-5 = [ { type = "show-workspace"; name = "5"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-6 = [ { type = "show-workspace"; name = "6"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-7 = [ { type = "show-workspace"; name = "7"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-8 = [ { type = "show-workspace"; name = "8"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-9 = [ { type = "show-workspace"; name = "9"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-0 = [ { type = "show-workspace"; name = "10"; } { type = "warp-mouse-to-focus"; target = "output"; } ];

        # move window & follow
        logo-shift-1 = [ { type = "move-to-workspace"; name = "1"; } { type = "show-workspace"; name = "1"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-shift-2 = [ { type = "move-to-workspace"; name = "2"; } { type = "show-workspace"; name = "2"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-shift-3 = [ { type = "move-to-workspace"; name = "3"; } { type = "show-workspace"; name = "3"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-shift-4 = [ { type = "move-to-workspace"; name = "4"; } { type = "show-workspace"; name = "4"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-shift-5 = [ { type = "move-to-workspace"; name = "5"; } { type = "show-workspace"; name = "5"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-shift-6 = [ { type = "move-to-workspace"; name = "6"; } { type = "show-workspace"; name = "6"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-shift-7 = [ { type = "move-to-workspace"; name = "7"; } { type = "show-workspace"; name = "7"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-shift-8 = [ { type = "move-to-workspace"; name = "8"; } { type = "show-workspace"; name = "8"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-shift-9 = [ { type = "move-to-workspace"; name = "9"; } { type = "show-workspace"; name = "9"; } { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-shift-0 = [ { type = "move-to-workspace"; name = "10"; } { type = "show-workspace"; name = "10"; } { type = "warp-mouse-to-focus"; target = "output"; } ];

        logo-h = [ "focus-tiles" "focus-left" { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-j = [ "focus-tiles" "focus-down" { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-k = [ "focus-tiles" "focus-up" { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-l = [ "focus-tiles" "focus-right" { type = "warp-mouse-to-focus"; target = "output"; } ];

        logo-Left  = [ "focus-tiles" "focus-left" { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-Down  = [ "focus-tiles" "focus-down" { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-Up    = [ "focus-tiles" "focus-up" { type = "warp-mouse-to-focus"; target = "output"; } ];
        logo-Right = [ "focus-tiles" "focus-right" { type = "warp-mouse-to-focus"; target = "output"; } ];

        ctrl-alt-F1 = { type = "switch-to-vt"; num = 1; };
        ctrl-alt-F2 = { type = "switch-to-vt"; num = 2; };
        ctrl-alt-F3 = { type = "switch-to-vt"; num = 3; };
        ctrl-alt-F4 = { type = "switch-to-vt"; num = 4; };
        ctrl-alt-F5 = { type = "switch-to-vt"; num = 5; };
        ctrl-alt-F6 = { type = "switch-to-vt"; num = 6; };
        ctrl-alt-F7 = { type = "switch-to-vt"; num = 7; };
      };

      windows = [
        { match = { any = [ { app-id = "discord"; } { app-id = "vesktop"; } { app-id = "spotify"; } { app-id = "com.obsproject.Studio"; } ]; }; action = [ { type = "move-to-output"; output = "Secondary"; } ]; }
        { match = { any = [ { app-id = "zen"; title = "Picture-in-Picture"; } { app-id = "firefox"; title = "Picture-in-Picture"; } ]; }; initial-tile-state = "floating"; action = [ "pin-float" "enable-float-above-fullscreen" ]; }
      ];

      clients = [
        { match = { comm = "waybar"; }; capabilities = [ "layer-shell" "workspace-manager" "foreign-toplevel-manager" ]; }
        { match = { comm = "awww-daemon"; }; capabilities = [ "layer-shell" ]; }
        { match = { comm = "swaync"; }; capabilities = [ "layer-shell" ]; }
        { match = { exe-regex = "wl-(copy|paste)"; }; capabilities = [ "data-control" ]; }
        { match = { comm = "swaylock"; }; capabilities = [ "session-lock" "layer-shell" ]; }
        { match = { comm = "wayfreeze"; }; capabilities = [ "layer-shell" "screencopy" ]; }
        { match = { comm = "grim"; }; capabilities = [ "screencopy" ]; }
        { match = { comm = "slurp"; }; capabilities = [ "layer-shell" ]; }
      ];
    };
  };
}
