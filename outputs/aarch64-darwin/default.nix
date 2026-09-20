# Flake outputs for the aarch64-darwin system (the darwin platform).
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
  platformName = "darwin";
  configurationsAttr = "darwinConfigurations";
  srcDir = ./src;
  testsDir = ./tests;
}
