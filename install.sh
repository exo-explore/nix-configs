#!/usr/bin/env bash
set -euo pipefail
CONFIG_DIR="$HOME/nix-configs"
LACIE_DRIVE="/volumes/LaCie"
if [ -f "$CONFIG_DIR/flake.lock" ]; then
        cd "$CONFIG_DIR"
else
        mkdir -p "$CONFIG_DIR"
        curl -fsSL "https://api.github.com/repos/exo-explore/nix-configs/tarball/main" | tar -xzf - --strip-components=1 -C "$CONFIG_DIR"
        cd "$CONFIG_DIR"
fi

if command -v nix >/dev/null 2>&1; then
        echo "Nix already installed"
else
        echo "Installing nix"
        bash <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
        NIX=$(command -v nix || echo "/nix/var/nix/profiles/default/bin/nix") # Fallback just in case
fi

NIX=$(command -v nix)
OS=$(uname -s)
if [ "$OS" = "Darwin" ]; then
        sudo "$NIX" --extra-experimental-features "nix-command flakes" run nix-darwin/master#darwin-rebuild -- switch --flake .#"$(whoami)"
elif [ "$OS" = "Linux" ]; then
        sudo "$NIX" --extra-experimental-features "nix-command flakes" run nixpkgs#nixos-rebuild -- switch --flake .#"$(hostname)"
else
        echo "Unsupported os $OS"
        exit 1
fi

if [ -n "$LACIE_DRIVE" ] && [ -f "$LACIE_DRIVE/.env" ]; then
        # shellcheck disable=SC1091
        . "$LACIE_DRIVE/.env"
fi

