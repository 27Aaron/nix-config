{inputs, ...}: {
  imports = [
    ./network.nix
    ./hardware.nix
    "${inputs.my-secrets}/hosts/hkg-dmit-01/proxy.nix"
  ];

  # HKG DMIT 1C-2G-60G

  # Infrastructure
  security'.firewall.enable = true;
  services'.openssh.enable = true;
  services'.vnstat.enable = true;

  # Proxy
  services'.sing-box.enable = true;
  services'.snell-server.enable = true;
}
