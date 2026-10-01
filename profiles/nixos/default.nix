{
  # Compose shared NixOS modules with the common Home Manager setup.
  imports = [
    ../../modules/nixos
    ../../modules/home
    ../../modules/home/nixos
  ];
}
