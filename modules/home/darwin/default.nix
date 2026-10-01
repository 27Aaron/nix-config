{ ... }:
{
  # Load Home Manager modules that require nix-darwin.
  hm'.imports = [
    ./karabiner.nix
    ./nh.nix
  ];
}
