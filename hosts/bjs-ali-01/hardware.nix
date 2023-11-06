{
  lib,
  pkgs,
  ...
}: {
  # Platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Boot
  boot'.grub.enable = true;
  boot'.initrd-ssh.enable = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];

    kernelParams = [
      "audit=0"
      "ip=dhcp"
      "net.ifnames=0"
    ];
  };

  # Hardware
  hardware'.disable-balloon.enable = true;
  hardware'.disko-luks = {
    enable = true;
    device = "/dev/vda";
  };
  hardware'.qemu.enable = true;

  # Memory
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryMax = 2 * 1024 * 1024 * 1024 + 1024 * 1024;
    memoryPercent = 500;
    priority = 5;
  };
}
