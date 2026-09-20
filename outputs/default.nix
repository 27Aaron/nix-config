# Assemble all flake outputs.
#
# Host outputs live under outputs/<system>/: one file per host in src/,
# with the host's eval tests next to it in tests/. This file merges the
# per-system outputs and adds the flake-level outputs (checks, devShells,
# formatter).
inputs@{
  self,
  nixpkgs,
  ...
}:
let
  inherit (nixpkgs) lib;

  myvars = import ../helpers/constants/user.nix;
  port = (import ../helpers/constants/ports.nix { inherit lib; }).port;

  args = {
    inherit
      inputs
      lib
      myvars
      port
      ;
  };

  systems = {
    aarch64-darwin = import ./aarch64-darwin (args // { system = "aarch64-darwin"; });
    x86_64-linux = import ./x86_64-linux (args // { system = "x86_64-linux"; });
  };

  systemNames = builtins.attrNames systems;
  systemValues = builtins.attrValues systems;

  configurations = {
    darwinConfigurations = lib.attrsets.mergeAttrsList (
      map (it: it.darwinConfigurations or { }) systemValues
    );
    nixosConfigurations = lib.attrsets.mergeAttrsList (
      map (it: it.nixosConfigurations or { }) systemValues
    );
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
    evalTestFailures = lib.flatten (map (it: it.evalTests or [ ]) systemValues);
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
