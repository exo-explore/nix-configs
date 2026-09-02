{ config, pkgs, self, ... }:
{
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Install firefox.
  programs.firefox.enable = true;
  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    self.packages.x86_64-linux.update
    neovim
    curl
    wget
    git
    just
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  system.stateVersion = "25.11"; # Did you read the comment?
}
