{
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./carapace
    ./niri.nix
    ./nushell
    ./starship
    ./waybar
    ./wlogout.nix
    ./yazi
  ];
}
