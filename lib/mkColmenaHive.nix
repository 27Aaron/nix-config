# Build the `colmenaHive` flake output (colmena 0.5 schema) from the evaluated
# nixosConfigurations instead of `lib.makeHive`, which would re-evaluate every
# host. Schema mirrors colmena's src/nix/hive/eval.nix; update on __schema bumps.
{
  lib,
  nixosConfigurations,
}:
let
  toplevel = lib.mapAttrs (_: host: host.config.system.build.toplevel) nixosConfigurations;
  deploymentConfig = lib.mapAttrs (_: host: host.config.deployment) nixosConfigurations;

  selectNames = names: lib.filterAttrs (name: _: builtins.elem name names);
in
{
  __schema = "v0.5";

  metaConfig = {
    name = "nix-config";
    description = "Aaron's Nix configurations";
    # Refuse `colmena apply` without an explicit --on filter, so a bare
    # apply can never touch the whole fleet by accident.
    allowApplyAll = false;
  };

  nodes = nixosConfigurations;
  inherit toplevel deploymentConfig;

  deploymentConfigSelected = names: selectNames names deploymentConfig;
  evalSelected = names: selectNames names toplevel;
  evalSelectedDrvPaths = names: lib.mapAttrs (_: drv: drv.drvPath) (selectNames names toplevel);

  introspect =
    f:
    f {
      inherit lib;
      pkgs = (lib.head (lib.attrValues nixosConfigurations)).pkgs;
      nodes = nixosConfigurations;
    };
}
