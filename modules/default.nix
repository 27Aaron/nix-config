platformName: {lib, ...}: let
  platforms = {
    darwin = ./darwin;
    nixos = ./nixos;
  };

  listModules = directory:
    lib.pipe (builtins.readDir directory) [
      (lib.mapAttrsToList (
        name: type: let
          path = directory + "/${name}";
          isNixDirectory = builtins.pathExists (path + "/default.nix");
          isNixFile = type == "regular" && lib.hasSuffix ".nix" name;
        in
          if type == "directory"
          then
            if isNixDirectory
            then [path]
            else listModules path
          else lib.optional isNixFile path
      ))
      lib.flatten
    ];
in {
  imports = listModules ./common ++ listModules platforms.${platformName};
}
