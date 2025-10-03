#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$HOME/nix-configs"
LACIE_DRIVE="/volumes/LaCie"

run_rebuild() {
        local NIX
        NIX=$(command -v nix)
        local OS
        OS=$(uname -s)
        cd "$CONFIG_DIR" || exit 1
        if [ "$OS" = "Darwin" ]; then
                sudo "$NIX" --extra-experimental-features "nix-command flakes" run nix-darwin/master#darwin-rebuild -- switch --flake .#"$(whoami)"
        elif [ "$OS" = "Linux" ]; then
                sudo "$NIX" --extra-experimental-features "nix-command flakes" run nixpkgs#nixos-rebuild -- switch --flake .#"$(hostname)"
        else
                echo "Unsupported os $OS"
                exit 1
        fi
}

if [ -n "$LACIE_DRIVE" ] && [ -f "$LACIE_DRIVE/.env" ]; then
        # shellcheck disable=SC1091
        . "$LACIE_DRIVE/.env"

        if [ -n "$GH_KEYFILE" ]; then
                mkdir -p "$HOME/.ssh"
                touch "$HOME/.ssh/config"
                chmod 600 "$HOME/.ssh/config"
                cp "$LACIE_DRIVE/$GH_KEYFILE" "$HOME/.ssh/exogru_gh_key"
                chmod 600 "$HOME/.ssh/exogru_gh_key"
                grep -q "Host github.com" "$HOME/.ssh/config" || cat >> "$HOME/.ssh/config" <<'EOF'

Host github.com
User git
IdentityFile ~/.ssh/exogru_gh_key
IdentitiesOnly yes
EOF
                echo "Copied github keyfile"
        fi
fi

if [ ! -f "$CONFIG_DIR/flake.lock" ]; then
        rm -rf "$CONFIG_DIR"
        mkdir -p "$CONFIG_DIR"
        curl -fsSL "https://api.github.com/repos/exo-explore/nix-configs/tarball/main" | tar -xzf - --strip-components=1 -C "$CONFIG_DIR"
fi

if ! command -v nix >/dev/null 2>&1; then
        echo "Installing nix"
        bash <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
fi

run_rebuild

# And, reclone the flake as a git repo instead of as a tarball
if [ ! -d "$CONFIG_DIR/.git" ]; then
        rm -rf "$CONFIG_DIR"
        git clone git@github.com:exo-explore/nix-configs "$CONFIG_DIR"
        run_rebuild
        echo "Rebuilt with latest flake"
fi

if [ -n "$TS_KEY" ]; then
        sudo tailscale up --authkey "$TS_KEY"
        echo "Authenticated tailscale"
fi

