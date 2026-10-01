{
  # Compose shared NixOS modules with the common Home Manager setup.
  imports = [
    ../../modules/nixos
    ../../modules/nixos/hardware/disko.nix
    ../../modules/nixos/hardware/persistence.nix
    ../../modules/home
    ../../modules/home/nixos
  ];
}
