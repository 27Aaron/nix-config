{
  lib,
  myvars,
  ...
}:
let
  listModules =
    dir:
    lib.pipe (builtins.readDir dir) [
      (lib.mapAttrsToList (
        name: type:
        let
          path = dir + "/${name}";
          isNixDir = builtins.pathExists (path + "/default.nix");
          isNixFile = type == "regular" && lib.hasSuffix ".nix" name;
        in
        if type == "directory" then
          if isNixDir then path else listModules path
        else
          lib.optional isNixFile path
      ))
      lib.flatten
    ];
in
{
  imports = lib.concatMap listModules [
    ./programs
    ./shell
  ];

  home = {
    username = myvars.username;
    homeDirectory = myvars.path.homeDirectory;
    stateVersion = "26.05";

    # better ls sorting
    language.collate = "C.UTF-8";
  };

  # The second switch is what skips building the option manual; man.enable alone does not.
  programs.man.enable = false;
  manual.manpages.enable = false;
}
