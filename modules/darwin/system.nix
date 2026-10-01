{ pkgs, username, ... }:
{
  programs.fish.enable = true;

  users.users.${username}.shell = pkgs.fish;
  environment.shells = [ pkgs.fish ];
}
