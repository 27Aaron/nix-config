{
  hostName,
  pkgs,
  ...
}:
{
  # Use Fish as the login shell.
  programs.fish.enable = true;

  user'.shell = pkgs.fish;
  environment.shells = [ pkgs.fish ];
  system.defaults.smb.NetBIOSName = hostName;
}
