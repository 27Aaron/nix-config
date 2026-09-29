# Build every nixos host entry into a flake configuration.
{
  lib,
  hosts,
  inputs,
  myvars,
  ...
}:
let
  mkNixos =
    name: host:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs myvars;
        hostName = name;
      };
      modules = [
        (import ../nixos)
      ]
      ++ host.modules
      ++ [
        {
          nixpkgs.hostPlatform = lib.mkDefault host.system;
          system.stateVersion = lib.mkDefault host.stateVersion;
        }
      ];
    };

  nixosHosts = lib.filterAttrs (_: host: host.class == "nixos") hosts;
in
{
  config.flake.nixosConfigurations = lib.mapAttrs mkNixos nixosHosts;
}
