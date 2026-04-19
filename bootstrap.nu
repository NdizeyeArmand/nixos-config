#!/usr/bin/env nu

const HW_SRC       = "/etc/nixos/hardware-configuration.nix"
const DEFAULT_NAME = "voyager"
const HOSTS_MARKER = "          # HOSTS_END"

def is_valid_hostname [name: string] {
    $name =~ '^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$'
}

def prompt_host_name [] {
    let raw = (input $"Name for the new machine \(blank = '($DEFAULT_NAME)'\): " | str trim)

    if ($raw | is-empty) {
        print $"No name given — using default: ($DEFAULT_NAME)"
        return $DEFAULT_NAME
    }

    if not (is_valid_hostname $raw) {
        print $"'($raw)' is not a valid hostname (alphanumeric + hyphens, no leading/trailing hyphen)."
        print $"Using default: ($DEFAULT_NAME)"
        return $DEFAULT_NAME
    }

    $raw
}

def make_flake_block [host: string] {
$"          ($host) = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              ./parts/hosts/($host)
              {
                nixpkgs.config.allowUnfreePredicate =
                  pkg:
                  builtins.elem \(nixpkgs.lib.getName pkg\) [
                    \"vscode\"
                  ];
              }
              niri.nixosModules.niri
              sops-nix.nixosModules.sops
              stylix.nixosModules.stylix
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.($env.USER) = ./parts/home;
                home-manager.backupFileExtension = \"backup\";
                home-manager.extraSpecialArgs = { inherit inputs; };
              }
            ];
          };"
}

def scaffold_host [host: string, template: string, dotfiles: string] {
    let host_dir     = ($dotfiles | path join "parts" "hosts" $host)
    let template_dir = ($dotfiles | path join "parts" "hosts" $template)
    let hw_dst       = ($host_dir | path join "hardware-configuration.nix")

    if not ($template_dir | path exists) {
        error make { msg: $"Template host '($template)' not found at ($template_dir)" }
    }
    if ($host_dir | path exists) {
        error make { msg: $"Host '($host)' already exists at ($host_dir) — aborting to avoid overwrite." }
    }

    print $"Scaffolding '($host)' from template '($template)'..."
    cp -r $template_dir $host_dir

    print "Replacing hardware-configuration.nix..."
    sudo cp $HW_SRC $hw_dst
}

def update_flake [host: string, dotfiles: string] {
    let flake_path = ($dotfiles | path join "flake.nix")
    let content    = (open --raw $flake_path)

    if not ($content | str contains $HOSTS_MARKER) {
        error make { msg: $"Marker '($HOSTS_MARKER)' not found in ($flake_path).\nAdd it just before the closing '};' of nixosConfigurations." }
    }

    let new_block   = (make_flake_block $host)
    let replacement = $"($new_block)\n          ($HOSTS_MARKER)"
    let updated     = ($content | str replace $HOSTS_MARKER $replacement)

    $updated | save --force $flake_path
    print $"flake.nix updated — added '($host)' to nixosConfigurations."
}

def update_hostname [host: string, dotfiles: string] {
    let config_path = ($dotfiles | path join "parts" "hosts" $host "configuration.nix")
    let content = (open --raw $config_path)

    let updated = ($content | str replace --regex 'networking\.hostName\s*=\s*"[^"]*"' $'networking.hostName = "($host)"')

    if $updated == $content {
        print $"⚠  Could not find networking.hostName in ($config_path) — set it manually."
    } else {
        $updated | save --force $config_path
        print $"Updated networking.hostName = \"($host)\" in configuration.nix"
    }
}

def main [
    --template (-t): string = "cassini"
] {
    let dotfiles = ($env.HOME | path join "dotfiles")

    if not ($dotfiles | path exists) {
        error make { msg: $"Dotfiles not found at ($dotfiles)" }
    }
    if not ($HW_SRC | path exists) {
        error make { msg: $"No hardware config at ($HW_SRC) — are you on a fresh NixOS install?" }
    }

    let host = (prompt_host_name)

    scaffold_host   $host $template $dotfiles
    update_flake    $host $dotfiles
    update_hostname $host $dotfiles
    
    print "\nScaffolding complete."
    print $"  → Review hardware config if anything looks unexpected:"
    print $"    ($dotfiles)/parts/hosts/($host)/hardware-configuration.nix"

    let answer = (input "\nRebuild now? (y/n) " | str trim | str downcase)
    if $answer == "y" {
        sudo nixos-rebuild switch --flake $"($dotfiles)#($host)"
    } else {
        print $"\nWhen ready: sudo nixos-rebuild switch --flake ($dotfiles)#($host)"
    }
}
