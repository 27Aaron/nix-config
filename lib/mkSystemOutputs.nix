# Build the flake outputs for one system: host configurations are derived
# from the directories under hosts/<platform>/, and the eval tests under
# outputs/<system>/tests/ assert the frozen invariants of a host.
#
# Adding a host means creating hosts/<platform>/<name>/default.nix; the
# flake output (and its eval test, if any) are picked up automatically.
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

  # A host is a directory under hosts/<platform>/ that has a default.nix.
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
