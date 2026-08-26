{
  # MacBook Pro M-series
  ...
}: {
  system.stateVersion = 6;

  apps'.homebrew.enable = true;
  security'.touch-id.enable = true;
  system'.defaults.enable = true;

  nixpkgs.hostPlatform = "aarch64-darwin";
}
