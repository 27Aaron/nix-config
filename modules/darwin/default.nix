{ pkgs, ... }:
{
  imports = [
    ./defaults.nix
    ./homebrew.nix
    ./nix.nix
  ];

  # Use Fish as the login shell.
  programs.fish.enable = true;

  user'.shell = pkgs.fish;
  environment.shells = [ pkgs.fish ];
}
