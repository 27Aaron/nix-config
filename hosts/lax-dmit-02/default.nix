{inputs, ...}: {
  imports = [
    ./network.nix
    ./hardware.nix
    "${inputs.my-secrets}/hosts/lax-dmit-02/proxy.nix"
    "${inputs.my-secrets}/hosts/lax-dmit-02/containers.nix"
  ];

  # LAX DMIT MALIBU 1C-1G-20G

  # Infrastructure
  security'.firewall.enable = true;
  services'.openssh.enable = true;
  services'.vnstat.enable = true;

  # Application
  services'.caddy.enable = true;

  # Container
  services'.podman.enable = true;
  containers'.sub-store.enable = true;

  # Proxy
  services'.snell-server.enable = true;
  services'.sing-box.enable = true;
}
