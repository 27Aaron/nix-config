{
  # Compose the shared system and Home Manager modules with the laptop session.
  imports = [
    ./default.nix
    ../../modules/nixos/laptop.nix
  ];
}
