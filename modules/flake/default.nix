# Flake-level entry point. Everything the flake needs on top of flake.nix
# lives in this tree, so flake.nix itself stays a thin shell.
{ ... }:
{
  imports = [
    ./inventory.nix
    ./hosts.nix
    ./treefmt.nix
  ];
}
