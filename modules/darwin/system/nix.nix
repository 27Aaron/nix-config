{ pkgs, ... }:
{
  nix = {
    enable = true;
    package = pkgs.lixPackageSets.stable.lix;
  };
}
