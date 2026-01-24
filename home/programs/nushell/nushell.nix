{ pkgs, lib, ... }:
{
  programs.nushell = {
    enable = true;
    extraConfig = ''
      # Set config values directly
      $env.config.buffer_editor = "hx"
      $env.config.show_banner = false
      $env.config.completions.case_sensitive = false
      $env.config.completions.quick = true
      $env.config.completions.partial = true
      $env.config.completions.algorithm = "fuzzy"
      $env.config.completions.external.enable = true
      $env.config.completions.external.max_results = 100

      # Define completers BEFORE referencing them
      let carapace_completer = {|spans: list<string>|
          carapace $spans.0 nushell ...$spans
          | from json
          | if ($in | default [] | where value == $"($spans | last)ERR" | is-empty) { $in } else { null }
      }

      $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

      let zoxide_completer = {|spans|
          $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
      }

      let multiple_completers = {|spans|
          # alias fixer start
          let expanded_alias = scope aliases
          | where name == $spans.0
          | get -o 0.expansion

          let spans = if $expanded_alias != null {
            $spans
            | skip 1
            | prepend ($expanded_alias | split row ' ' | take 1)
          } else {
            $spans
          }
          # alias fixer end

          match $spans.0 {
            __zoxide_z | __zoxide_zi => $zoxide_completer
            _ => $carapace_completer
          } | do $in $spans
      }

      # NOW set the completer to use the variable
      $env.config.completions.external.completer = $multiple_completers

      # Your yazi integration
      def --env y [...args] {
        let tmp = (mktemp -t "yazi-cwd.XXXXXX")
        yazi ...$args --cwd-file $tmp
        let cwd = (open $tmp)
        if $cwd != "" and $cwd != $env.PWD {
          cd $cwd
        }
        rm -fp $tmp
      }
    '';

    shellAliases = {
      vi = "hx";
      vim = "hx";
      nano = "hx";
      g = "git";
      lla = "ls -la";
      la = "ls -a";
      ll = "ls -l";
      l = "ls";
    };
  };
}
