{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    (writeScriptBin "zathura-opener" ''
      #!/usr/bin/env nu 
      def main [
        filename: string
      ] {
        let basename = ($filename | path parse | get stem)
        let pdf_path = ($basename + ".pdf")
        ^zathura $pdf_path
      }
    '')
  ];
  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_macchiato";
      editor = {
        shell = [
          "nu"
          "-c"
        ];
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
      keys.normal.space.z = ":sh zathura-opener %{buffer_name}";
    };
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
          language-servers = [ "nil" ];
        }
        {
          name = "java";
          language-servers = [ "jdtls" ];
          scope = "source.java";
          injection-regex = "java";
          file-types = [ "java" ];
          roots = [
            "pom.xml"
            "build.gradle"
          ];
          indent = {
            tab-width = 4;
            unit = "    ";
          };
        }
        {
          name = "elm";
          language-servers = [ "elm-language-server" ];
        }
        {
          name = "haskell";
          language-servers = [ "haskell-language-server" ];
        }
        {
          name = "php";
          language-servers = [ "phpactor" ];
        }
        {
          name = "rust";
          language-servers = [ "rust-analyzer" ];
        }
        {
          name = "go";
          language-servers = [ "gopls" ];
        }
        {
          name = "typst";
          language-servers = [ "tinymist" ];
        }
        {
          name = "typescript";
          language-servers = [ "typescript-language-server" ];
        }
      ];
      language-server.tinymist = {
        command = "tinymist";
        config = {
          exportPdf = "onType";
        };
      };
      language-server.hls = {
        command = "haskell-language-server-wrapper";
        args = [ "--lsp" ];
      };
      language-server.nil = {
        command = "${pkgs.nil}/bin/nil";
      };
      language-server.jdtls = {
        command = "jdt-language-server";
        args = [
          "-data"
          "/home/<USER>/.cache/jdtls/workspace"
        ];
      };
      language-server.jdtls.config.java.inlayHints = {
        parameterNames.enabled = "all";
      };
    };
    # themes = {
    #   nord_night_transparent = {
    #     "inherits" = "nord_night";
    #     "ui.background" = { };
    #   };
    # };
  };
}
