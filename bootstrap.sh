#!/usr/bin/env bash
set -e

# Get the host argument (default to current hostname if not provided)
TARGET_HOST="${1:-$HOSTNAME}"

DOTFILES="$HOME/dotfiles"
HOST_DIR="$DOTFILES/parts/hosts/$TARGET_HOST"

# Check if this is a valid/explicit host selection
if [[ "$TARGET_HOST" == "desktop" ]] || [[ "$TARGET_HOST" == "server" ]]; then
    echo "Updating hardware-configuration.nix for explicit host: $TARGET_HOST"
    
    sudo cp /etc/nixos/hardware-configuration.nix "$HOST_DIR/"
    
    echo "Hardware config updated. Review $HOST_DIR/configuration.nix for any needed changes."
    
else
    # Fallback to acer directory
    echo "Updating hardware-configuration.nix for default host (acer)..."
    ACER_DIR="$DOTFILES/parts/hosts/acer"
    sudo cp /etc/nixos/hardware-configuration.nix "$ACER_DIR/"
    HOST_DIR="$ACER_DIR"
    TARGET_HOST="acer"
fi

# Single rebuild prompt
read -p "Rebuild system now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo nixos-rebuild switch --flake "$DOTFILES#$TARGET_HOST"
fi
