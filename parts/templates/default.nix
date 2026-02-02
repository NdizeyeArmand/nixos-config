{
  ...
}:
{
  flake.templates = {
    elm = {
      path = ./elm;
      description = "Elm dev environment";
    };
    haskell = {
      path = ./haskell;
      description = "Haskell dev environment";
    };
    java = {
      path = ./java;
      description = "Java dev environment";
    };
    go = {
      path = ./go;
      description = "Go dev environment";
    };
    rust = {
      path = ./rust;
      description = "Rust dev environment";
    };
    typescript = {
      path = ./typescript;
      description = "Typescript dev environment";
    };
    typst = {
      path = ./typst;
      description = "Typst dev environment";
    };
  };
}
