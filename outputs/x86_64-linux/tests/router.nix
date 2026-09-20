{
  configurations,
  lib,
  ...
}:
let
  config = configurations.nixosConfigurations.router.config;

  # Server role: no desktop stack and no user tool suites.
  expectations = {
    "desktop'.greetd.enable" = false;
    "desktop'.niri.enable" = false;
    "development'.ai.enable" = false;
    "development'.dev.enable" = false;
  };

  failures = lib.mapAttrsToList (
    path: expected:
    let
      actual = lib.attrByPath (lib.splitString "." path) null config;
    in
    lib.optional (
      actual != expected
    ) "router: ${path} = ${builtins.toJSON actual}, expected ${builtins.toJSON expected}"
  ) expectations;
in
lib.flatten failures
