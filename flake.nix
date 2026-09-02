{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
      genHosts = prefix: num: map (i: "${prefix}${toString i}") (builtins.genList (i: i + 1) num);
      hostsWithDefaultConfig =
        (genHosts "s" 18)
        ++ (genHosts "e" 18)
        ++ (genHosts "puffin" 16)
        ++ (genHosts "demo" 4)
        ++ [
          "helios"
          "selene"
        ];

      nixSettings = name: {
        trusted-users = [ "root" name ];
        extra-experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    in
    {
      packages.aarch64-darwin.update = inputs.nixpkgs.legacyPackages."aarch64-darwin".writeShellScriptBin "update" ''
        exec ${inputs.nix-darwin.packages.aarch64-darwin.darwin-rebuild}/bin/darwin-rebuild switch --flake "github:exo-explore/nix-configs''${1:+#$1}"
      '';
      packages.x86_64-linux.update = inputs.nixpkgs.legacyPackages.x86_64-linux.writeShellScriptBin "update" ''
        exec ${inputs.nixpkgs.legacyPackages.x86_64-linux.nixos-rebuild-ng}/bin/nixos-rebuild switch --flake "github:exo-explore/nix-configs''${1:+#$1}"
      '';
      nixosConfigurations = lib.genAttrs [ "minos" ] (name: lib.nixosSystem {
	specialArgs = { inherit (inputs) self; };
        modules = [
	  (./hosts + "/${name}.nix")
	  (./hosts + "/${name}-hardware.nix")
	  ./nixos_configuration.nix
	  {
            nix.settings = nixSettings name;
            nixpkgs.config.allowUnfree = true;
            networking.hostName = name;
            users.users.${name} = {
              isNormalUser = true;
              extraGroups = [ "networkmanager" "wheel" ];
              # packages = with pkgs; [ ];
            };
	  }
	];
      });
      darwinConfigurations = lib.genAttrs hostsWithDefaultConfig (
        name:
        inputs.nix-darwin.lib.darwinSystem {
	  specialArgs = { inherit (inputs) self; };
          modules = [
            {
              nix.settings = nixSettings name;
              networking.hostName = name;
              system.defaults.loginwindow.autoLoginUser = name;
            }
            ./darwin_configuration.nix
          ];
        }
      );
    };
}
