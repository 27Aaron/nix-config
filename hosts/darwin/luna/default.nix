{
  # MacBook Pro M-series
  ...
}: {
  system.stateVersion = 6;

  apps'.ai-cli.enable = true;
  apps'.homebrew.enable = true;
  security'.touch-id.enable = true;
  system'.defaults.enable = true;
  tools'.dev.enable = true;

  nixpkgs.hostPlatform = "aarch64-darwin";
}
