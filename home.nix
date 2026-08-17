{ config, pkgs, ... }:

{
  home.username = "xv";
  home.homeDirectory = "/home/xv";
  home.stateVersion = "26.05";

  # ==============================================================================
  # 1. PACKAGES (Waywall binary installed here)
  # ==============================================================================
  home.packages = with pkgs; [
    waywall
  ];

  # ==============================================================================
    # JAY COMPOSITOR
    # ==============================================================================
    wayland.windowManager.jay.enable = true;
    xdg.configFile."jay/config.toml".source = ./jay/config.toml;

  # ==============================================================================
  # 2. FILE SYMLINKS (Waywall config folder linked here)
  # ==============================================================================
  xdg.configFile."waywall" = {
	      source = ./waywall;
	      recursive = true;
	    };
  xdg.configFile."waybar".source = ./waybar;  
  xdg.configFile."micro/settings.json".source = ./micro/bindings.json;
  xdg.configFile."swaylock/config".source = ./swaylock/config;
  home.file.".zshrc".source = ./zshrc;

  # ==============================================================================
  # 3. NIXCRAFT CONFIGURATION
  # ==============================================================================
  nixcraft.client.instances."technical-setup" = {
    version = "1.20.4";
  };

  # ==============================================================================
  # 4. MANGO
  # ==============================================================================
  wayland.windowManager.mango = {
    enable = true;
    systemd.enable = true;

    # AUTOSTART (exec-once)
    autostart_sh = ''
      swaync &
      awww-daemon &
      swaybg -i /home/xv/Downloads/image.png &
    '';

    # EXTRA CONFIG (for options like reload notifications)
    extraConfig = ''
      exec = notify-send "MangoWM" "Configuration reloaded successfully!" -i preferences-system
    '';

    settings = {
      # ENVIRONMENT VARIABLES
      env = [
        "XDG_CURRENT_DESKTOP,mango"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,mango"
        "SHELL,/usr/bin/zsh"
        "QT_QPA_PLATFORM,wayland;xcb"
        "GDK_BACKEND,wayland,x11"
        "MOZ_ENABLE_WAYLAND,1"
      ];

      # MONITORS
      monitorrule = [
        "name:eDP-1, width:1920, height:1080, refresh:144.000, x:0, y:0, scale:1"
      ];

      # INPUT & BEHAVIOR
      mouse_accel_speed = "-0.96";
      trackpad_accel_speed = "0.33";
      trackpad_accel_profile = 1;
      mouse_accel_profile = 1;
      trackpad_natural_scrolling = 1;
      tap_to_click = 1;
      sloppyfocus = 0;
      warpcursor = 1;
      focus_cross_monitor = 1;
      drag_tile_to_tile = 1;

      # DWINDLE LAYOUT
      circle_layout = "dwindle,fair";
      dwindle_split_ratio = "0.5";
      dwindle_smart_split = 0;
      dwindle_hsplit = 1;
      dwindle_vsplit = 1;
      dwindle_preserve_split = 0;
      dwindle_smart_resize = 0;
      dwindle_drop_simple_split = 1;

      # APPEARANCE
      gappih = 2;
      gappiv = 2;
      gappoh = 3;
      gappov = 3;
      blur = 1;
      blur_optimized = 1;
      smartgaps = 1;
      focuscolor = "1A1B26";
      tag_animation_direction = 0;

      # WINDOW & TAG RULES
      windowrule = [
        "isfloating:1, appid:^(org\\.wezfurlong\\.wezterm)$"
        "isfloating:1, isglobal:1, appid:firefox, title:^(Picture-in-Picture)$"
        "isfloating:1, appid:^(me\\.kavishdevar\\.librepods)$"
      ];

      tagrule = [
        "id:1,layout_name:dwindle"
        "id:2,layout_name:dwindle"
        "id:3,layout_name:dwindle"
        "id:4,layout_name:dwindle"
        "id:5,layout_name:dwindle"
        "id:6,layout_name:dwindle"
        "id:7,layout_name:dwindle"
        "id:8,layout_name:dwindle"
        "id:9,layout_name:dwindle"
      ];

      # KEYBINDINGS
      bind = [
        # Applications
        "SUPER, Return, spawn, ghostty"
        "SUPER, p, spawn, fuzzel"
        "SUPER+ALT, l, spawn, swaylock"
        "SUPER, x, spawn, swaync-client -t -sw"

        # System & Window Management
        "SUPER, q, killclient"
        "SUPER+SHIFT, q, quit"
        "SUPER+SHIFT, f, togglefullscreen"
        "SUPER, f, togglemaximizescreen"
        "SUPER+SHIFT, SPACE, togglefloating"
        "SUPER, r, reload_config"
        "SUPER, tab, toggleoverview"
        "SUPER, m, togglegaps"

        # Layouts
        "SUPER, backslash, switch_layout"
        "SUPER+SHIFT, backslash, setlayout, dwindle"

        # Screenshots
        "SUPER+SHIFT, s, spawn, sh -c 'grim -g \"$(slurp)\" - | wl-copy'"
        "SUPER+SHIFT, m, spawn, sh -c 'grim -g \"$(slurp)\" - | swappy'"

        # Focus Movement
        "SUPER, h, focusdir, left"
        "SUPER, j, focusdir, down"
        "SUPER, k, focusdir, up"
        "SUPER, l, focusdir, right"
        "SUPER, Left, focusdir, left"
        "SUPER, Down, focusdir, down"
        "SUPER, Up, focusdir, up"
        "SUPER, Right, focusdir, right"

        # Media & Volume
		"NONE, XF86AudioRaiseVolume, spawn, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"
        "NONE, XF86AudioLowerVolume, spawn, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"
        "NONE, XF86AudioMute, spawn, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        "NONE, XF86AudioMicMute, spawn, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"        "NONE, XF86AudioPlay, spawn, playerctl play-pause"
        "NONE, XF86AudioStop, spawn, playerctl stop"
        "NONE, XF86AudioPrev, spawn, playerctl previous"
        "NONE, XF86AudioNext, spawn, playerctl next"

        # Backlight
        "NONE, f4, spawn, brightnessctl --class=backlight set +5%"
        "NONE, f3, spawn, brightnessctl --class=backlight set 5%-"

        # Workspaces - View
        "SUPER, 1, view, 1"
        "SUPER, 2, view, 2"
        "SUPER, 3, view, 3"
        "SUPER, 4, view, 4"
        "SUPER, 5, view, 5"
        "SUPER, 6, view, 6"
        "SUPER, 7, view, 7"
        "SUPER, 8, view, 8"
        "SUPER, 9, view, 9"

        # Workspaces - Tag Window
        "SUPER+SHIFT, 1, tag, 1"
        "SUPER+SHIFT, 2, tag, 2"
        "SUPER+SHIFT, 3, tag, 3"
        "SUPER+SHIFT, 4, tag, 4"
        "SUPER+SHIFT, 5, tag, 5"
        "SUPER+SHIFT, 6, tag, 6"
        "SUPER+SHIFT, 7, tag, 7"
        "SUPER+SHIFT, 8, tag, 8"
        "SUPER+SHIFT, 9, tag, 9"
      ];

      # MOUSE & GESTURE BINDINGS
      mousebind = [
        "SUPER, btn_left, moveresize, curmove"
        "SUPER, btn_right, moveresize, curresize"
      ];

      axisbind = [
        "SUPER, UP, viewtoleft_have_client"
        "SUPER, DOWN, viewtoright_have_client"
      ];
    };
  };
}
