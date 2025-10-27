{ pkgs, ... }: {
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    fd
    fzf
    git
    helix # Modal CLI text editor
    wget # Tool for retrieving files using HTTP, HTTPS, and FTP
    findutils # GNU Find Utilities, the basic directory searching utilities of the GNU operating system
  ];
}
