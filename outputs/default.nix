# Assemble all flake outputs.
#
# Per-system outputs (host configurations and their eval tests) come from
# lib/mkSystemOutputs.nix; this file merges them and adds the flake-level
# outputs (checks, devShells, formatter).
inputs@{
  self,
  nixpkgs,
  ...
}:
let
  inherit (nixpkgs) lib;

  myvars = import ../helpers/constants/user.nix;
  port = (import ../helpers/constants/ports.nix).port;

  systems = {
    aarch64-darwin = import ../lib/mkSystemOutputs.nix {
      inherit
        inputs
        lib
        myvars
        port
        ;
      system = "aarch64-darwin";
    };
    x86_64-linux = import ../lib/mkSystemOutputs.nix {
      inherit
        inputs
        lib
        myvars
        port
        ;
      system = "x86_64-linux";
    };
  };

  systemNames = builtins.attrNames systems;
  systemValues = builtins.attrValues systems;

  configurations = {
    inherit (systems.aarch64-darwin) darwinConfigurations;
    inherit (systems.x86_64-linux) nixosConfigurations;
  };

  forEachSystem = lib.genAttrs systemNames;

  # Remote deployment via colmena (see the `deploy` recipe). Built from the
  # evaluated nixosConfigurations so hosts are never evaluated twice.
  colmenaHive = import ../lib/mkColmenaHive.nix {
    inherit lib;
    inherit (configurations) nixosConfigurations;
  };
in
configurations
// {
  inherit colmenaHive;

  checks = import ./checks.nix {
    inherit
      self
      nixpkgs
      configurations
      colmenaHive
      systemNames
      ;
    evalTestFailures = lib.flatten (map (it: it.evalTests) systemValues);
  };

  devShells = forEachSystem (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      default = pkgs.mkShellNoCC {
        packages = [
          inputs.colmena.packages.${system}.colmena
          pkgs.deadnix
          pkgs.just
          pkgs.nixfmt-rs
        ];
      };
    }
  );

  formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-rs);
}
