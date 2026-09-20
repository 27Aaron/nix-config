# Flake outputs for the x86_64-linux system (the nixos platform).
{
  inputs,
  lib,
  myvars,
  port,
  system,
  ...
}:
import ../../lib/mkSystemOutputs.nix {
  inherit
    inputs
    lib
    myvars
    port
    system
    ;
  platformName = "nixos";
  configurationsAttr = "nixosConfigurations";
  srcDir = ./src;
  testsDir = ./tests;
}
