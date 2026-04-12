{ ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      scan_timeout = 30;

      directory = {
        truncation_length = 4;
        truncate_to_repo = true;
        style = "bold blue";
      };

      git_branch = {
        symbol = " ";
        style = "bold green";
      };

      git_status = {
        style = "bold yellow";
        ahead = "⇡$count";
        behind = "⇣$count";
        modified = "~$count";
        staged = "+$count";
      };

      cmd_duration = {
        min_time = 5000;
        style = "bold yellow";        
      };

      nix_shell = {
        symbol = "❄️ ";
        style = "bold purple";        
      };
      
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };
}
