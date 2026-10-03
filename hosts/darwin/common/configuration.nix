{
  hostName,
  timeZone,
  username,
  ...
}:
{
  networking.hostName = hostName;
  networking.computerName = hostName;

  system.primaryUser = username;
  system.stateVersion = 6;

  user'.home = "/Users/${username}";

  time.timeZone = timeZone;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
