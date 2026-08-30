{
  lib,
  myvars,
  platformName,
  ...
}: let
  platforms = {
    darwin = {
      directory = ./darwin;
      homeDirectory = "/Users/${myvars.username}";
    };
    nixos = {
      directory = ./nixos;
      homeDirectory = "/home/${myvars.username}";
    };
  };

  platform = platforms.${platformName};
  moduleDirectories = [
    ./common
    platform.directory
  ];
  modules =
    lib.concatMap (
      directory:
        builtins.filter
        (path: lib.hasSuffix ".nix" (toString path))
        (lib.filesystem.listFilesRecursive directory)
    )
    moduleDirectories;
in {
  imports = modules;

  home = {
    username = myvars.username;
    inherit (platform) homeDirectory;
    stateVersion = "26.05";
  };

  # The second switch is what skips building the option manual; man.enable alone does not.
  programs.man.enable = false;
  manual.manpages.enable = false;
}
