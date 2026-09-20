# Build the `colmenaHive` flake output (colmena 0.5 schema) from the
# evaluated nixosConfigurations.
#
# Colmena's own `lib.makeHive` re-evaluates every node from scratch, which
# would evaluate the whole NixOS configuration a second time. Mapping the
# existing nixosConfigurations instead reuses the evaluation that
# `nix flake check` and the build commands already perform, so hosts are
# never evaluated twice. The schema is what `colmena.lib.makeHive` emits
# (see colmena's src/nix/hive/eval.nix); update this file when colmena
# bumps __schema.
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
