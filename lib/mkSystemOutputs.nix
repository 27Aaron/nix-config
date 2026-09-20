# Flake outputs for one system: host configurations from hosts/<platform>/ and
# the eval tests under outputs/<system>/tests/. Adding hosts/<platform>/<name>/
# default.nix is enough — the output and its eval test are picked up automatically.
{
  inputs,
  lib,
  myvars,
  system,
}:
let
  isDarwin = lib.hasSuffix "-darwin" system;
  platformName = if isDarwin then "darwin" else "nixos";
  configurationsAttr = if isDarwin then "darwinConfigurations" else "nixosConfigurations";

  scanPaths = (import ./default.nix { inherit lib; }).scanPaths;

  hostsDir = ../hosts + "/${platformName}";
  testsDir = ../outputs + "/${system}/tests";

  mkHost =
    hostName:
    import ./mkHost.nix {
      inherit
        inputs
        myvars
        platformName
        hostName
        ;
    };

  hostNames = builtins.attrNames (
    lib.filterAttrs (
      name: type: type == "directory" && builtins.pathExists (hostsDir + "/${name}/default.nix")
    ) (builtins.readDir hostsDir)
  );

  outputs = {
    ${configurationsAttr} = lib.genAttrs hostNames mkHost;
  };

  # Eval tests: one file per host under tests/; each returns failure
  # messages. A platform without a tests directory simply has none.
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
