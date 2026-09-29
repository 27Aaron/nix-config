# Assemble all flake outputs: per-system ones (host configurations and the
# colmena hive) from hosts/default.nix, plus flake-level ones (checks,
# devShells, formatter).
inputs@{
  self,
  nixpkgs,
  ...
}:
let
  inherit (nixpkgs) lib;

  myvars = import ../vars;

  systems = {
    x86_64-linux = import ../hosts {
      inherit
        inputs
        lib
        myvars
        ;
    };
  };

  systemNames = builtins.attrNames systems;
  # The host configurations are Linux-only. Keep the formatter available on
  # the Darwin workstation used to maintain this repository.
  formatterSystems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];

  configurations = {
    inherit (systems.x86_64-linux) nixosConfigurations;
  };

  # Remote deployment via colmena (see the `deploy` recipe). Built from the
  # evaluated nixosConfigurations so hosts are never evaluated twice.
  colmenaHive = (systems.x86_64-linux).colmenaHive;
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
    };

  devShells = lib.genAttrs systemNames (
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

  formatter = lib.genAttrs formatterSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rs);
}
