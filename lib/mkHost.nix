{
  inputs,
  myvars,
  platformName,
  platform,
  hostName,
}:
let
  helpers = import ../helpers { inherit (inputs.nixpkgs) lib; };

  specialArgs = {
    inherit
      inputs
      myvars
      hostName
      platformName
      helpers
      ;
  };
in
platform.builder {
  inherit specialArgs;

  modules = [
    (import ../modules platformName)
    platform.homeManagerModule
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-bak";
        extraSpecialArgs = specialArgs;
        users.${myvars.username}.imports = [ ../home ];
      };
    }
    (../hosts + "/${platformName}/${hostName}")
  ];
}
