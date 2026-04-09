{ ... }:
{
  programs.vesktop = {
    enable = true;
    vencord.themes = {
      midnight = builtins.fetchurl {
        url = "https://refact0r.github.io/midnight-discord/build/midnight.css";
        sha256 = "0kgsa1wdpv5jpvcpz6igpcny90a00zv7qf94cxk3l6wvd0df9n8d";
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
