{ pkgs, self, ... }:
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
    neovim
    git
    just
    gh
    lazygit
    ripgrep
    nixfmt-tree
    tailscale
    python3
    uv
    self.packages.aarch64-darwin.update
    podman
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
}
