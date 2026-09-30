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
    let
      specialArgs = {
        inherit inputs myvars;
        hostName = name;
      };
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit specialArgs;
      modules = [
        (import ../nixos)
        inputs.home-manager.nixosModules.home-manager
        ({ config, ... }: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-bak";
            extraSpecialArgs = specialArgs // {
              osConfig = config;
            };
            users.${myvars.username}.imports = [
              ../../modules/home/common
              ../../modules/home/nixos
            ];
          };
        })
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
