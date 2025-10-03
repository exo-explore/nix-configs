#!/usr/bin/env bash
if nix --version >/dev/null 2>&1; then
        echo "Nix already installed"
else
        echo "Installing nix"
        bash <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
fi
cd ~ || exit 1
if [ -d ~/nix-configs/.git ]; then
        cd nix-configs || exit 1
        git pull
else
        git clone https://github.com/exo-explore/nix-configs
        cd nix-configs || exit 1
fi
sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin/master#darwin-rebuild -- switch --flake .#"$(whoami)"
gh auth login
