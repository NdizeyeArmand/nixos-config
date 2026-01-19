{
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./niri.nix
    ./waybar
    ./wlogout.nix
    ./yazi
  ];
}
