#####################################################
#
# Luna - MacBook Pro 2023 16-inch
#   (M2 Max, 96 GB RAM, 4 TB SSD)
#
#####################################################
{ ... }:
{
  programs'.homebrew.enable = true;
  core'.defaults.enable = true;

  development'.dev.enable = true;

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
}
