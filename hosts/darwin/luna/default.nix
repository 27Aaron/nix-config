# Luna — primary MacBook Pro (M2 Max, 96 GB unified memory, 2 TB SSD).
{...}: {
  apps'.homebrew.enable = true;
  security'.touch-id.enable = true;
  system'.defaults.enable = true;
  tools' = {
    ai-cli.enable = true;
    dev.enable = true;
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.stateVersion = 6;
}
