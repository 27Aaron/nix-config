{
  description = "Aaron's Nix configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    llm-agents.url = "github:numtide/llm-agents.nix";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:nix-community/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.stable.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      myvars = import ./vars;
      hostOutputs = import ./hosts { inherit inputs lib myvars; };
      nixosConfigurations = hostOutputs.nixosConfigurations;

      checks.x86_64-linux =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        {
          format = pkgs.runCommand "check-format" { nativeBuildInputs = [ pkgs.nixfmt-rs ]; } ''
            nixfmt --check ${self}
            touch $out
          '';

          deadnix = pkgs.runCommand "check-deadnix" { nativeBuildInputs = [ pkgs.deadnix ]; } ''
            deadnix --fail ${self}
            touch $out
          '';

          eval = pkgs.runCommand "check-eval" {
            drvPaths = lib.concatStringsSep " " (
              lib.mapAttrsToList (
                _: host: lib.unsafeDiscardStringContext host.config.system.build.toplevel.drvPath
              ) nixosConfigurations
            );
            hive = builtins.toJSON {
              inherit (hostOutputs.colmenaHive) __schema deploymentConfig;
            };
          } "touch $out";
        };

      devShells.x86_64-linux.default =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.mkShellNoCC {
          packages = [
            inputs.colmena.packages.x86_64-linux.colmena
            pkgs.deadnix
            pkgs.just
            pkgs.nixfmt-rs
          ];
        };

      formatter = {
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rs;
        aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rs;
      };
    in
    {
      inherit
        checks
        devShells
        formatter
        nixosConfigurations
        ;
      inherit (hostOutputs) colmenaHive;
    };
}
