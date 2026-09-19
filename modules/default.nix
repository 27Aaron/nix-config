platformName:
{
  lib,
  inputs,
  myvars,
  ...
}:
let
  inherit (import ../lib { inherit lib; }) scanPaths;
  platforms = import ../lib/platforms.nix { inherit inputs myvars; };
in
{
  imports = scanPaths ./common ++ scanPaths platforms.${platformName}.modulesPath;
}
