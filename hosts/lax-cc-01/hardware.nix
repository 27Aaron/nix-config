{
  lib,
  pkgs,
  ...
}: {
  # Platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Boot
  boot'.grub.enable = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];

    kernelParams = ["audit=0" "net.ifnames=0"];
  };

  # Hardware
  hardware'.disable-balloon.enable = true;
  hardware'.disko = {
    enable = true;
    device = "/dev/vda";
  };
  hardware'.qemu.enable = true;

  # Memory
  zramSwap = {
    enable = true;
    priority = 5;
    algorithm = "zstd";
    memoryPercent = 500;
    memoryMax = 2 * 1024 * 1024 * 1024 + (1024 * 1024);
  };
}
