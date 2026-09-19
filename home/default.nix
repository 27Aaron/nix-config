{
  lib,
  inputs,
  myvars,
  platformName,
  ...
}:
let
  inherit (import ../lib { inherit lib; }) scanPaths;
  platforms = import ../lib/platforms.nix { inherit inputs myvars; };
  platform = platforms.${platformName};
in
{
  imports = scanPaths ./common ++ scanPaths platform.homeModulesPath;

  home = {
    username = myvars.username;
    inherit (platform) homeDirectory;
    stateVersion = "26.05";
  };

  # The second switch is what skips building the option manual; man.enable alone does not.
  programs.man.enable = false;
  manual.manpages.enable = false;
}
