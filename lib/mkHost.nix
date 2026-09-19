{
  inputs,
  myvars,
  platformName,
  platform,
  hostName,
}:
let
  specialArgs = {
    inherit
      inputs
      myvars
      hostName
      platformName
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
