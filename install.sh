#!/usr/bin/env bash
set -euo pipefail
if [ -f ~/nix-configs/flake.lock ]; then
        cd ~/nix-configs
else
        cd ~
        curl -fsSL https://github.com/exo-explore/nix-configs/archive/refs/heads/main.zip -o main.zip
        unzip main.zip -d ~/nix-configs
        rm main.zip
        cd ~/nix-configs
fi
NIX=/nix/var/nix/profiles/default/bin/nix
if $NIX --version >/dev/null 2>&1; then
        echo "Nix already installed"
else
        echo "Installing nix"
        bash <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
fi
sudo $NIX --extra-experimental-features "nix-command flakes" run nix-darwin/master#darwin-rebuild -- switch --flake .#"$(whoami)"
gh auth login
