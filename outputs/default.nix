# Assemble all flake outputs: per-system ones (host configurations and eval tests)
# from lib/mkSystemOutputs.nix, plus flake-level ones (checks, devShells, formatter).
inputs@{
  self,
  nixpkgs,
  ...
}:
let
  inherit (nixpkgs) lib;

  myvars = import ../vars;

  systems = {
    x86_64-linux = import ../lib/mkSystemOutputs.nix {
      inherit
        inputs
        lib
        myvars
        ;
      system = "x86_64-linux";
    };
  };

  systemNames = builtins.attrNames systems;
  systemValues = builtins.attrValues systems;
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
