{
  lib,
  inputs,
  myvars,
  platformName,
  helpers,
  ...
}:
let
  inherit (import ../lib { inherit lib; }) scanPaths;
  platforms = import ../lib/platforms.nix { inherit inputs; };
  platform = platforms.${platformName};
in
{
  imports = scanPaths ./common ++ scanPaths platform.homeModulesPath;

  home = {
    username = myvars.username;
    inherit (helpers.path) homeDirectory;
    stateVersion = "26.05";

    # better ls sorting
    language.collate = "C.UTF-8";
  };

  # The second switch is what skips building the option manual; man.enable alone does not.
  programs.man.enable = false;
  manual.manpages.enable = false;
}
