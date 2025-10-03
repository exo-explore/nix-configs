{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          power = {
            sleep = {
              # Apply to both charger and battery
              display = "never"; # never turn off display
              harddisk = "never"; # never system sleep
              computer = "never"; # never spin down disks
            };
          };
          services = {
            # SSH server
            openssh.enable = true;
            # Tailscale
            tailscale.enable = true;
          };

          environment.systemPackages = with pkgs; [
            vim
            git
            just
            gh
            lazygit
            ripgrep
            nixfmt-tree
            tailscale
            darwin.PowerManagement
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
          nix.settings.extra-experimental-features = [
            "nix-command"
            "flakes"
          ];
          nix.enable = false;
        };
        
        genHosts = n: map (i: "s${toString i}") (builtins.genList (i: i + 1) n);
        hostsWithDefaultConfig = genHosts 18 ++ [];
    in
    {
      darwinConfigurations = nixpkgs.lib.genAttrs hostsWithDefaultConfig (
        _:
        nix-darwin.lib.darwinSystem {
          modules = [ configuration ];
        }
      );
    };
}
