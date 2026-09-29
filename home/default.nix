{
  lib,
  myvars,
  ...
}:
let
  listModules =
    directory:
    builtins.filter (path: lib.hasSuffix ".nix" (toString path)) (
      lib.filesystem.listFilesRecursive directory
    );
in
{
  imports = listModules ./common;

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
