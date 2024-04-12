{inputs, ...}: {
  imports = [
    ./network.nix
    ./hardware.nix
    "${inputs.my-secrets}/network/lax-dmit-03/proxy.nix"
  ];

  # LAX DMIT Echo 1C-1G-20G

  # Infrastructure
  security'.firewall.enable = true;
  services'.openssh.enable = true;
  services'.vnstat.enable = true;

  # Proxy
  services'.sing-box.enable = true;
  services'.snell-server.enable = true;
}
