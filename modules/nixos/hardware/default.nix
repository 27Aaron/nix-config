{ ... }:
{
  imports = [
    ./amdgpu.nix
    ./bluetooth.nix
    ./boot
    ./disable-balloon.nix
    ./disko.nix
    ./persistence.nix
  ];
}
