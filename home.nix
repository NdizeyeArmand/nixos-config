{ config, pkgs, ... }: {
  home.username = "armand";
  home.homeDirectory = "/home/armand";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    tor-browser-bundle-bin # Privacy-focused browser routing traffic through the Tor network
    firefox
    # mullvad # Mullvad VPN command-line client tools
    # qbittorrent # OpenSource Qt Bittorrent client
    yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
    vlc # Media Player
    # dim # Self-hosted media manager
    # zellij # Terminal workspace with batteries included
    # niri # Scrollable-tiling Wayland compositor
    jq
    rucola # Terminal-based markdown note manager
    zathura # zathura
    nushell # Modern shell written in Rust
    ghostty # Fast, native, feature-rich terminal emulator pushing modern features
    yazi # Terminal file manager
    # claude-code # Agentic coding tool
    bitwarden-cli # Secure and free password manager for all of your devices
    wiki-tui # Simple and easy to use Wikipedia Text User Interface
    # hledger # CLI for the hledger accounting system 
  ];

  programs.git = {
    enable = true;
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
}
