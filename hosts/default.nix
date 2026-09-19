{
  inputs,
  myvars,
}:
let
  inherit (inputs.nixpkgs) lib;

  platforms = import ../lib/platforms.nix { inherit inputs; };

  mkHost =
    platformName: platform: hostName: _:
    import ../lib/mkHost.nix {
      inherit
        inputs
        myvars
        platformName
        platform
        hostName
        ;
    };

  mkConfigurations =
    platformName: platform:
    lib.pipe (builtins.readDir (./. + "/${platformName}")) [
      (lib.filterAttrs (
        hostName: type:
        type == "directory" && builtins.pathExists (./. + "/${platformName}/${hostName}/default.nix")
      ))
      (lib.mapAttrs (mkHost platformName platform))
    ];
in
lib.mapAttrs' (
  platformName: platform:
  lib.nameValuePair "${platformName}Configurations" (mkConfigurations platformName platform)
) platforms
