{inputs, ...}: {
  imports = [
    ./network.nix
    ./hardware.nix
    "${inputs.my-secrets}/hosts/lax-dmit-01/proxy.nix"
    "${inputs.my-secrets}/hosts/lax-dmit-01/services.nix"
  ];

  # LAX DMIT WEE 1C-1G-20G

  # Infrastructure
  security'.firewall.enable = true;
  services'.openssh.enable = true;
  services'.vnstat.enable = true;

  # Application
  services'.caddy.enable = true;
  services'.pocket-id.enable = true;

  # Database
  services'.postgresql.enable = true;

  # Proxy
  services'.snell-server.enable = true;
}
