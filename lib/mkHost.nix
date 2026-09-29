{
  inputs,
  myvars,
  hostName,
}:
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
    (../hosts + "/nixos/${hostName}")
  ];
}
