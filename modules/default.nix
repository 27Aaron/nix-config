platformName:
{
  lib,
  inputs,
  ...
}:
let
  inherit (import ../lib { inherit lib; }) scanPaths;
  platforms = import ../lib/platforms.nix { inherit inputs; };
in
{
  imports = scanPaths ./common ++ scanPaths platforms.${platformName}.modulesPath;
}
