# Build the flake outputs for one system: host declarations under src/ and
# the eval tests under tests/.
#
# Each file in src/ declares the flake outputs of one host (e.g.
# `nixosConfigurations.<name> = mkHost "<name>"`), and each file in tests/
# asserts the frozen invariants of one host. Both directories are loaded
# with scanPaths, so adding a host means adding one file to each.
{
  inputs,
  lib,
  myvars,
  port,
  system,
  platformName,
  configurationsAttr,
  srcDir,
  testsDir,
}:
let
  platform = (import ./platforms.nix { inherit inputs; }).${platformName};
  scanPaths = (import ./default.nix { inherit lib; }).scanPaths;
  assertions = import ./assertions.nix { inherit lib; };

  mkHost =
    hostName:
    import ./mkHost.nix {
      inherit
        inputs
        myvars
        platformName
        platform
        hostName
        ;
    };

  # Host output declarations: one file per host under src/.
  hostData = map (
    file:
    import file {
      inherit
        inputs
        lib
        myvars
        system
        mkHost
        ;
    }
  ) (scanPaths srcDir);

  outputs = {
    ${configurationsAttr} = lib.attrsets.mergeAttrsList (
      map (it: it.${configurationsAttr} or { }) hostData
    );
  };

  # Eval tests: one file per host under tests/; each returns failure messages.
  evalTests = lib.flatten (
    map (
      file:
      import file {
        inherit
          lib
          assertions
          port
          system
          ;
        configurations = outputs;
      }
    ) (scanPaths testsDir)
  );
in
outputs
// {
  inherit evalTests;
}
