{inputs, ...}: {
  imports = [
    ./network.nix
    ./hardware.nix
    "${inputs.my-secrets}/network/lax-dmit-01/proxy.nix"
    "${inputs.my-secrets}/network/lax-dmit-01/services.nix"
  ];

  # LAX DMIT WEE 1C-1G-20G

  # Infrastructure
  security'.firewall.enable = true;
  services'.openssh.enable = true;
  services'.vnstat.enable = true;

  # Application stack
  services'.caddy.enable = true;
  services'.postgresql.enable = true;
  services'.snell-server.enable = true;
  services'.pocket-id.enable = true;
}
