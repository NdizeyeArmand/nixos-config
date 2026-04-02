{ pkgs, config, ... }:
{
  imports = [
    ./programs
    ../modules
  ];

  home.username = "armand";
  home.homeDirectory = "/home/armand";
  home.stateVersion = "26.05";

  # Assist with reloading and restarting systemd units
  systemd.user.startServices = "sd-switch";

  programs.fuzzel.enable = true;
  programs.swaylock.enable = true;
  services.swayidle.enable = true;
  services.polkit-gnome.enable = true;
  services.udiskie.enable = true;

  home.packages = with pkgs; [
    # Browsing
    # tor-browser # Privacy-focused browser routing traffic through the Tor network
    # mullvad # Mullvad VPN command-line client tools
    dejsonlz4

    # File management
    nemo
    rucola # Terminal-based markdown note manager
    file
    xdg-utils
    pandoc
    watchexec
    glow

    # Niri essentials
    swaybg # Wallpaper
    swayimg # Image viewer
    wl-clipboard # Clipboard utilities (wl-copy, wl-paste)
    grim # Screenshot tool
    slurp # Region selector for screenshots
    wlogout

    # Media
    pavucontrol
    obs-studio
    obs-cmd
    yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
    vlc # Media Player
    # dim # Self-hosted media manager
    # qbittorrent # OpenSource Qt Bittorrent client

    # Coding
    zellij # Terminal workspace with batteries included
    curl
    # claude-code # Agentic coding tool

    # Misc
    brightnessctl
    nixd
    cmatrix
    htop
    # bitwarden-cli # Secure and free password manager for all of your devices
    # wiki-tui # Simple and easy to use Wikipedia Text User Interface
    # hledger # CLI for the hledger accounting system
  ];

  myConfig.wallpaper = {
    enable = true;
    imageDir = ../modules/img;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings.user.name = "Dark_Loon";
    settings.user.email = "armandgaeln@gmail.com";
    settings.alias = {
      co = "checkout";
      st = "status";
    };
  };
  
  systemd.user.services.set-default-volume = {
    Unit = {
      Description = "Set default sink volume on login";
      After = [ "pipewire-pulse.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ 50%";
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.blueman-applet = {
    Unit = {
      Description = "Blueman applet";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.blueman}/bin/blueman-applet";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.firefox-bookmark-sync = {
    Unit = {
      Description = "Export Firefox bookmarks to dotfiles";
      After = [ "graphical-session.target" ];
      StartLimitIntervalSec = 60;
      StartLimitBurst = 5;
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.nushell}/bin/nu %h/dotfiles/parts/home/programs/firefox/bookmark-sync.nu";
      Environment = "HOME=%h";
    };
  };

  systemd.user.services.firefox-bookmark-sync = {
    description = "Sync Firefox bookmarks";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "%h/dotfiles/parts/home/programs/firefox/bookmark-sync.nu";
    };
  };

  systemd.user.paths.firefox-bookmark-sync = {
    Unit.Description = "Watch Firefox places.sqlite for changes";
    pathConfig = {
      PathChanged = "%h/.mozilla/firefox/profile_0/places.sqlite";
      Unit = "firefox-bookmark-sync.service";
    };
    wantedBy = [ "default.target" ];
  };

  systemd.user.timers.firefox-bookmark-sync = {
    Unit.Description = "Periodically sync Firefox bookmarks";
    timerConfig = {
      OnCalendar = "*:0/15";   # every 15 minutes
      Persistent = true;
      Unit = "firefox-bookmark-sync.service";
    };
    wantedBy = [ "timers.target" ];
  };
  
  xdg.configFile."yazi/plugins/glow.yazi/main.lua".source = ./programs/yazi/glow.lua;

  xdg.configFile."rucola/config.toml".text = ''
    file_types = ["markdown"]
    default_extension = "md"
    cache_index = false
    theme = "default_dark"
    stats_show = "Relevant"
    viewer = [
        "firefox",
        "-P",
        "Notes",
        "%p",
    ]
    secondary_viewer = ["glow", "%p"]
    css = "${config.home.homeDirectory}/.config/rucola/default_dark.css"
    katex = true

    [math_replacements]
    '\field' = '\mathbb'
  '';

  xdg.configFile."rucola/default_dark.css".text = ''
    body{
      max-width: 60%;
      margin: auto;
      background: #112c37;
    }

    p{
      font-size: 14px;
      color: #e2e8f3;
    }
    li{
      font-size: 14px;
      color: #e2e8f3;
    }

    h1{
      color: #6b84bd;
      font-size: 30px;
      font-family: "Times New Roman";
      font-style: italic;
    }

    h2{
      color: #6b84bd;
      font-size: 20px;
      font-family: "Times New Roman";
    }

    h3{
      color: #405b8c;
      font-size: 18px;
      font-family: "Times New Roman";
    }

    h4{
      color: #9bcfc8;
      font-size: 16px;
      font-family: "Times New Roman";
      font-style: italic;
    }

    a{  
      color: #6b84bd;
      text-decoration: none;
    }

    a:hover{
      color: #9bcfc8;
      text-decoration: underline;
    }
  '';

  xdg.desktopEntries.helix = {
    name = "Helix";
    genericName = "Text Editor";
    comment = "Fast modal text editor";
    exec = "foot hx %F";
    terminal = false;
    icon = "helix";
    categories = [
      "Utility"
      "TextEditor"
    ];
    mimeType = [
      "text/plain"
      "text/markdown"
      "application/x-nuscript"
      "application/octet-stream"
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.pwmt.zathura.desktop";
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "text/plain" = "helix.desktop";
      "application/x-nuscript" = "helix.desktop";
      "application/octet-stream" = "helix.desktop";
    };
  };
}
