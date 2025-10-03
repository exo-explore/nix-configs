#!/usr/bin/env bash
bash <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
cd ~ || exit 1
git clone https://github.com/exo-explore/nix-configs
cd nix-configs || exit 1
sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin/master#darwin-rebuild -- switch --flake .#"$(whoami)"
gh auth login
