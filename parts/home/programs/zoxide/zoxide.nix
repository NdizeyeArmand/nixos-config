{ pkgs, lib, ... }:
{
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };
}
