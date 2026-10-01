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
  user'.home = "/Users/${username}";

  time.timeZone = timeZone;
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
