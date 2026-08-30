#####################################################
#
# Luna - MacBook Pro 2023 16-inch
#   (M2 Max, 96 GB RAM, 4 TB SSD)
#
#####################################################
{...}: {
  apps'.homebrew.enable = true;
  security'.touch-id.enable = true;
  system'.defaults.enable = true;

  tools'.coding-agents.enable = true;
  tools'.dev.enable = true;

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
}
