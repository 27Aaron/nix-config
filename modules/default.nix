{
  lib,
  ...
}:
let
  inherit (import ../lib { inherit lib; }) scanPaths;
in
{
  imports = scanPaths ./common ++ scanPaths ./nixos;
}
