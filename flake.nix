{
  description = "Aaron's Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      # Discover host specifications from the directory tree.
      hostLib = import ./lib/hosts.nix { inherit lib; };

      nixosHosts = hostLib.discover ./hosts/nixos;
      darwinHosts = hostLib.discover ./hosts/darwin;

      # Build each host from its declared system and module list.
      mkNixosConfiguration =
        hostName: host:
        nixpkgs.lib.nixosSystem {
          system = host.system;
          specialArgs = {
            inherit inputs self hostName;
          }
          // (host.specialArgs or { });
          modules = [ home-manager.nixosModules.home-manager ] ++ (host.modules or [ ]);
        };

      mkDarwinConfiguration =
        hostName: host:
        nix-darwin.lib.darwinSystem {
          system = host.system;
          specialArgs = {
            inherit inputs self hostName;
          }
          // (host.specialArgs or { });
          modules = [
            home-manager.darwinModules.home-manager
            ./profiles/darwin
          ]
          ++ (host.modules or [ ]);
        };

      forEachSystem = lib.genAttrs lib.systems.flakeExposed;
    in
    {
      nixosConfigurations = lib.mapAttrs mkNixosConfiguration nixosHosts;
      darwinConfigurations = lib.mapAttrs mkDarwinConfiguration darwinHosts;

      # Format Nix source from standard input.
      formatter = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.writeShellScriptBin "nixfmt" ''
          input="$(cat)"
          if [ -z "$input" ]; then
            exit 0
          fi

          printf '%s\n' "$input" | ${pkgs.nixfmt-rs}/bin/nixfmt -
        ''
      );
    };
}
