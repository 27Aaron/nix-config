{inputs, ...}: {
  imports = [
    ./network.nix
    ./hardware.nix
    "${inputs.my-secrets}/network/lax-dmit-02/proxy.nix"
    "${inputs.my-secrets}/network/lax-dmit-02/containers.nix"
  ];

  # LAX DMIT MALIBU 1C-1G-20G

  # Infrastructure
  services'.vnstat.enable = true;
  services'.openssh.enable = true;
  security'.firewall.enable = true;

  # Application stack
  services'.caddy.enable = true;
  services'.podman.enable = true;
  services'.snell-server.enable = true;
  services'.sing-box.enable = true;

  containers'.sub-store.enable = true;
}
