{
  # Compose shared NixOS modules with the common Home Manager setup.
  imports = [
    ../../modules/nixos
    ../../modules/nixos/disko.nix
    ../../modules/nixos/persistence.nix
    ../../modules/home
    ../../modules/home/nixos
  ];
}
