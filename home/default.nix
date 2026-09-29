{
  lib,
  myvars,
  ...
}:
let
  inherit (import ../lib { inherit lib; }) scanPaths;
in
{
  imports = scanPaths ./common;

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
