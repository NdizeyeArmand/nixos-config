{
  description = "Dark Loon's NixOS flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    niri.url = "github:sodiboo/niri-flake";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      home-manager,
      niri,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];
      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
        };
      flake = {
        nixosConfigurations = {
          nixos = nixpkgs.lib.nixosSystem {
            modules = [
              ./system/configuration.nix
              {
                nixpkgs.config.allowUnfreePredicate =
                  pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "claude-code" ];
              }
              niri.nixosModules.niri
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.armand = ./home/home.nix;
                home-manager.backupFileExtension = "backup";

              }
            ];
          };
        };
      };
    };
}
