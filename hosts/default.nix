{
  inputs,
  lib,
  myvars,
}:
let
  mkHost =
    hostName:
    let
      specialArgs = {
        inherit
          inputs
          myvars
          hostName
          ;
      };
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit specialArgs;

      modules = [
        (import ../modules)
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-bak";
            extraSpecialArgs = specialArgs;
            users.${myvars.username}.imports = [ ../home ];
          };
        }
        (./. + "/${hostName}")
      ];
    };

  hostNames = builtins.attrNames (
    lib.filterAttrs (
      name: type: type == "directory" && builtins.pathExists (./. + "/${name}/default.nix")
    ) (builtins.readDir ./.)
  );

  nixosConfigurations = lib.genAttrs hostNames mkHost;

  toplevel = lib.mapAttrs (_: host: host.config.system.build.toplevel) nixosConfigurations;
  deploymentConfig = lib.mapAttrs (_: host: host.config.deployment) nixosConfigurations;
  selectNames = names: lib.filterAttrs (name: _: builtins.elem name names);

  colmenaHive = {
    __schema = "v0.5";

    metaConfig = {
      name = "nix-config";
      description = "Aaron's Nix configurations";
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
  };
in
{
  inherit
    colmenaHive
    nixosConfigurations
    ;
}
