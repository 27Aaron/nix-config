{
  lib,
  pkgs,
  inputs,
  ...
}: let
  secrets = import "${inputs.my-secrets}/hosts/nrt-gc-01/network.nix";
in {
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
      "audit=0"
      "net.ifnames=0"
      secrets.initrdIp
    ];
  };

  # Hardware
  hardware'.disable-balloon.enable = true;
  hardware'.disko = {
    enable = true;
    luks.enable = true;
    device = "/dev/vda";
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
