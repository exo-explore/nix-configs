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

          programs.zsh = {
            enable = true;
            interactiveShellInit = ''eval "$(direnv hook zsh)"'';
          };
          programs.direnv.enable = true;

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
        
        genHosts = prefix: num: map (i: "${prefix}${toString i}") (builtins.genList (i: i + 1) num);
        hostsWithDefaultConfig = (genHosts "s" 18) ++ (genHosts "puffin" 16) ++ ["helios" "selene"];
    in
    {
      darwinConfigurations = nixpkgs.lib.genAttrs hostsWithDefaultConfig (
        name:
        nix-darwin.lib.darwinSystem {
          modules = [ 
            { networking.hostName = name; }
            configuration 
          ];
        }
      );
    };
}
