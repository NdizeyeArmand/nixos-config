{ pkgs, ... }:
{
  programs.aider-chat = {
    enable = true;
    package = pkgs.aider-chat-with-playwright;
    settings = {
      architect = true;
      auto-accept-architect = false;
      cache-prompts = true;
      check-model-accepts-settings = false;
      dark-mode = true;
      dirty-commits = false;
      lint = true;
      show-model-warnings = false;
      verify-ssl = false;
    };
  };
}
