{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
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
              display = "never";
              harddisk = "never";
              computer = "never";
            };
          };
          services = {
            openssh.enable = true;
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
          ];

          homebrew = {
            enable = true;
            onActivation = {
              autoUpdate = true;
              cleanup = "uninstall";
              upgrade = true;
            };
          };

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;
          # Don't change unless you really know what you're doing!
          system.stateVersion = 6;
          nixpkgs.hostPlatform = "aarch64-darwin";
          nix.settings.extra-experimental-features = [
            "nix-command"
            "flakes"
          ];
        };
      homeConfig = {
        programs.zsh = {
          enable = true;
          interactiveShellInit = ''eval "$(direnv hook zsh)"'';
        };
        programs.direnv.enable = true;
      };
      homeManagerConfig = username: {
        home-manager.useGlobalPkgs = true;
        home-manager.users.${username} = homeConfig;
      };
      homebrewConfig = username: {
        nix-homebrew = {
          enable = true;
          user = username;
        };
      };
        
      genHosts = prefix: num: map (i: "${prefix}${toString i}") (builtins.genList (i: i + 1) num);
      hostsWithDefaultConfig = (genHosts "s" 18) ++ [];
      defaultModules = username: [ 
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        (homebrewConfig username)
        home-manager.darwinModules.home-manager
        homeManagerConfig
        (homeManagerConfig username)
      ];
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
