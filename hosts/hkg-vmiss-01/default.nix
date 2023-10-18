{inputs, ...}: {
  imports = [
    ./network.nix
    ./hardware.nix
    "${inputs.my-secrets}/network/hkg-vmiss-01/proxy.nix"
    "${inputs.my-secrets}/network/hkg-vmiss-01/services.nix"
  ];

  # HKG VMISS 1C-1G-10G

  # Infrastructure
  security'.firewall.enable = true;
  services'.openssh.enable = true;
  services'.vnstat.enable = true;

  # Application stack
  services'.caddy.enable = true;
  services'.sing-box.enable = true;
  services'.snell-server.enable = true;
}
