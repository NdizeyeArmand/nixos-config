{ ... }:
{
  programs.pandoc = {
    enable = true;
    templates = {
      "default.typst" = ./default.typ;
    };
  };
}
