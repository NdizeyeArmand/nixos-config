{ config, lib, pkgs, ... }:
{
  programs.vesktop = {
    enable = true;
    vencord.themes = {
      midnight = builtins.fetchurl {
        url = "https://refact0r.github.io/midnight-discord/build/midnight.css";
        sha256 = "146dvzkffvzf3c1j4s3m9myccz8bi2h37i3idspxkarh1a912d5y";
      };
    };    
    vencord.settings = {
      autoUpdate = true;
      autoUpdateNotification = true;
      enabledThemes = [ "midnight.css" ];
      notifyAboutUpdates = true;
      plugins = {
        ClearURLs.enabled = true;
        FixYoutubeEmbeds.enabled = true;
      };
    };
  };
}
