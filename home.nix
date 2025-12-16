{ config, pkgs, ... }: {
  home.username = "armand";
  home.homeDirectory = "/home/armand";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    # Browsing
    tor-browser-bundle-bin # Privacy-focused browser routing traffic through the Tor network
    # mullvad # Mullvad VPN command-line client tools

    # File management
    rucola # Terminal-based markdown note manager
    yazi # Terminal file manager
    zoxide # Fast cd command that learns your habits
    file
    xdg-utils
    kdePackages.okular # Universal document viewer
    nsxiv # Image viewer
    zathura # PDF viewer
    glow
    typst
    typstfmt

    # Media
    yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
    # vlc # Media Player
    # dim # Self-hosted media manager
    # qbittorrent # OpenSource Qt Bittorrent client

    # Coding
    nushell # Modern shell written in Rust
    starship # Minimal, blazing fast, and extremely customizable prompt for any shell
    ghostty # Fast, native, feature-rich terminal emulator pushing modern features
    zellij # Terminal workspace with batteries included
    # claude-code # Agentic coding tool        

    # Misc
    cmatrix
    # bitwarden-cli # Secure and free password manager for all of your devices
    # wiki-tui # Simple and easy to use Wikipedia Text User Interface
    # hledger # CLI for the hledger accounting system 
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Dark_Loon";
    userEmail = "armandgaeln@gmail.com";
    aliases = {
      co = "checkout";
      st = "status";
    };
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "autumn_night_transparent";
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
    };
    languages.language = [{
      name = "nix";
      auto-format = true;
      formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
    }];
    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = { };
      };
    };
  };

  programs.keychain = {
    enable = true;
    keys = [ "id_ed25519" ];
    agents = [ "ssh" ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = { "application/pdf" = "org.pwmt.zathura.desktop"; };
  };
}
