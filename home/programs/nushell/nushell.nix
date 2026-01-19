{ pkgs, lib, ... }:
{
  programs.nushell = {
    enable = true;
    extraConfig = ''
      def --env y [...args] {
      	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
      	^yazi ...$args --cwd-file $tmp
      	let cwd = (open $tmp)
      	if $cwd != $env.PWD and (path exists $cwd) {
      		cd $cwd
      	}
      	rm -fp $tmp
      }

      # Common ls aliases and sort them by type and then name
      # Inspired by https://github.com/nushell/nushell/issues/7190
      def lla [...args] { ls -la ...(if $args == [] {["."]} else {$args}) {{!}} sort-by type name -i }
      def la  [...args] { ls -a  ...(if $args == [] {["."]} else {$args}) {{!}} sort-by type name -i }
      def ll  [...args] { ls -l  ...(if $args == [] {["."]} else {$args}) {{!}} sort-by type name -i }
      def l   [...args] { ls     ...(if $args == [] {["."]} else {$args}) {{!}} sort-by type name -i }

      let carapace_completer = {{{!}}spans: list&lt;string&gt;{{!}}
          carapace $spans.0 nushell ...$spans
          | from json
          | if ($in | default [] {{!}} where value == $"($spans {{!}} last)ERR" {{!}} is-empty) { $in } else { null }
      }

      $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

      let zoxide_completer = {{{!}}spans{{!}}
            $spans {{!}} skip 1 {{!}} zoxide query -l ...$in {{!}} lines {{!}} where {{{!}}x{{!}} $x != $env.PWD}
      }

      let multiple_completers = {{{!}}spans{{!}}
          ## alias fixer start https://www.nushell.sh/cookbook/external_completers.html#alias-completions
          let expanded_alias = scope aliases
          | where name == $spans.0
          | get -o 0.expansion

          let spans = if $expanded_alias != null {
            $spans
            | skip 1
            | prepend ($expanded_alias | split row ' ' {{!}} take 1)
          } else {
            $spans
          }
          ## alias fixer end

          match $spans.0 {
            __zoxide_z {{!}} __zoxide_zi =&gt; $zoxide_completer
            _ =&gt; $carapace_completer
          } {{!}} do $in $spans
      }

      $env.config = {
        buffer_editor: "hx",  
        show_banner: false,
        completions: {
          case_sensitive: false # case-sensitive completions
          quick: true           # set to false to prevent auto-selecting completions
          partial: true         # set to false to prevent partial filling of the prompt
          algorithm: "fuzzy"    # prefix or fuzzy
          external: {
            # set to false to prevent nushell looking into $env.PATH to find more suggestions
            enable: true 
            # set to lower can improve completion performance at the cost of omitting some options
            max_results: 100 
            completer: $multiple_completers
          }
        }
      }'';

    shellAliases = {
      vi = "hx";
      vim = "hx";
      nano = "hx";
    };
  };
}
