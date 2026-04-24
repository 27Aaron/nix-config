{inputs, ...}: {
  imports = [
    ./network.nix
    ./hardware.nix
    "${inputs.my-secrets}/hosts/lax-hdz-01/proxy.nix"
    "${inputs.my-secrets}/hosts/lax-hdz-01/defuddle.nix"
  ];

  # LAX HostDZire 4C-6G-100G

  # Infrastructure
  security'.firewall.enable = true;
  services'.openssh.enable = true;
  services'.vnstat.enable = true;

  # Proxy
  services'.snell-server.enable = true;

  services'.caddy.enable = true;
  services'.defuddle.enable = true;
}
