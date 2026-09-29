{
  lib,
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
  imports = listModules ./common ++ listModules ./nixos;
}
