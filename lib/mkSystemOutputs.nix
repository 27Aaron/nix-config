# Flake outputs for one system: host configurations from hosts/nixos/.
# Adding hosts/nixos/<name>/default.nix is enough — the output is picked up
# automatically.
{
  inputs,
  lib,
  myvars,
}:
let
  hostsDir = ../hosts/nixos;

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
in
{
  nixosConfigurations = lib.genAttrs hostNames mkHost;
}
