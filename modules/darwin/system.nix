{ pkgs, username, ... }:
{
  # Use Fish as the login shell.
  programs.fish.enable = true;

  users.users.${username}.shell = pkgs.fish;
  environment.shells = [ pkgs.fish ];
}
