# Flake outputs for one system: host configurations from hosts/nixos/ and the
# eval tests under outputs/<system>/tests/. Adding hosts/nixos/<name>/default.nix
# is enough — the output and its eval test are picked up automatically.
{
  inputs,
  lib,
  myvars,
  system,
}:
let
  scanPaths = (import ./default.nix { inherit lib; }).scanPaths;

  hostsDir = ../hosts/nixos;
  testsDir = ../outputs + "/${system}/tests";

  mkHost =
    hostName:
    import ./mkHost.nix {
      inherit
        inputs
        myvars
        hostName
        ;
    };

  hostNames = builtins.attrNames (
    lib.filterAttrs (
      name: type: type == "directory" && builtins.pathExists (hostsDir + "/${name}/default.nix")
    ) (builtins.readDir hostsDir)
  );

  outputs = {
    nixosConfigurations = lib.genAttrs hostNames mkHost;
  };

  # Eval tests: one file per host under tests/; each returns failure messages.
  # A system without a tests directory simply has none.
  evalTests = lib.flatten (
    lib.optionals (builtins.pathExists testsDir) (
      map (
        file:
        import file {
          inherit lib;
          configurations = outputs;
        }
      ) (scanPaths testsDir)
    )
  );
in
outputs
// {
  inherit evalTests;
}
