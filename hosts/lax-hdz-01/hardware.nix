{
  lib,
  pkgs,
  ...
}: {
  # Platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Boot
  boot'.grub.enable = true;
  boot'.clevis.enable = true;
  boot'.initrd-ssh.enable = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];

    kernelParams = [
      "ip=dhcp"
      "audit=0"
      "net.ifnames=0"
    ];
  };

  # Hardware
  hardware'.disable-balloon.enable = true;
  hardware'.disko-luks = {
    enable = true;
    device = "/dev/sda";
  };
  hardware'.qemu.enable = true;

  # Memory
  zramSwap = {
    enable = true;
    priority = 5;
    algorithm = "zstd";
    memoryPercent = 500;
    memoryMax = 6 * 1024 * 1024 * 1024 + (1024 * 1024);
  };
}
