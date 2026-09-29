# Flake-level entry point. Everything the flake needs on top of flake.nix
# lives in this tree, so flake.nix itself stays a thin shell.
{ ... }:
{
  systems = [
    "aarch64-darwin"
    "x86_64-linux"
  ];

  imports = [ ./treefmt.nix ];
}
