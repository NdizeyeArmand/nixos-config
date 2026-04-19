{
  description = "Dark Loon's NixOS flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    niri.url = "github:sodiboo/niri-flake";
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixgl.url = "github:nix-community/nixGL";
    
    firefox-css = {
      url = "github:MrOtherGuy/firefox-csshacks";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };    
  };

  outputs =
    inputs@{
      flake-parts,
      niri,
      nixpkgs,
      sops-nix,
      stylix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./parts/templates
      ];
      systems = [
        "x86_64-linux"
      ];
      perSystem =
        {
          ...
        }:
        {
        };
      flake = {
        nixosConfigurations = {
          cassini = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              ./parts/hosts/cassini
              {
                nixpkgs.config.allowUnfreePredicate =
                  pkg:
                  builtins.elem (nixpkgs.lib.getName pkg) [
                    "vscode"
                  ];
              }
              niri.nixosModules.niri
              sops-nix.nixosModules.sops
              stylix.nixosModules.stylix
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.armand = ./parts/home;
                home-manager.backupFileExtension = "backup";
                home-manager.extraSpecialArgs = { inherit inputs; };
              }
            ];
          };
          odyssey = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              ./parts/hosts/odyssey
              {
                nixpkgs.config.allowUnfreePredicate =
                  pkg:
                  builtins.elem (nixpkgs.lib.getName pkg) [
                    "vscode"
                  ];
              }
              niri.nixosModules.niri
              sops-nix.nixosModules.sops
              stylix.nixosModules.stylix
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.armand = ./parts/home;
                home-manager.backupFileExtension = "backup";
                home-manager.extraSpecialArgs = { inherit inputs; };
              }
            ];
          };
          # HOSTS_END
        };
      };
    };
}
