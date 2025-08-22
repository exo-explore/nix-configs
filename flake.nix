{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            vim
            git
            just
            gh
            lazygit
	    ripgrep
            nixfmt-tree
          ];

          programs.zsh = {
            enable = true;
            interactiveShellInit = ''eval "$(direnv hook zsh)"'';
          };
          programs.direnv.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;
          # Don't change unless you really know what you're doing
          system.stateVersion = 6;
          nixpkgs.hostPlatform = "aarch64-darwin";
          nix.settings.experimental-features = "nix-command flakes";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#s1
      darwinConfigurations."s1" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
      darwinConfigurations."s2" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
      darwinConfigurations."s3" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
      darwinConfigurations."s4" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
    };
}
