#!/usr/bin/env bash
set -e

HOSTNAME="${1:-$(hostname)}"
DOTFILES="$HOME/dotfiles"
HOST_DIR="$DOTFILES/hosts/$HOSTNAME"
TEMPLATE_HOST="acer"  # Your template host

# Create host directory if it doesn't exist
if [ ! -d "$HOST_DIR" ]; then
    echo "Creating new host configuration for $HOSTNAME based on $TEMPLATE_HOST..."
    
    # Copy template host directory
    cp -r "$DOTFILES/hosts/$TEMPLATE_HOST" "$HOST_DIR"
    
    # Update hostname in configuration.nix
    sed -i "s/networking.hostName = \"$TEMPLATE_HOST\"/networking.hostName = \"$HOSTNAME\"/" "$HOST_DIR/configuration.nix"
    
    # Copy new hardware config
    sudo cp /etc/nixos/hardware-configuration.nix "$HOST_DIR/"
    
    echo "Host configuration created from $TEMPLATE_HOST template."
    echo "Hardware config updated. Review $HOST_DIR/configuration.nix for any needed changes."
else
    echo "Host directory already exists. Updating hardware-configuration.nix..."
    sudo cp /etc/nixos/hardware-configuration.nix "$HOST_DIR/"
fi

# Optionally rebuild immediately
read -p "Rebuild system now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo nixos-rebuild switch --flake "$DOTFILES#$HOSTNAME"
fi
