{inputs, ...}: {
  imports = [
    ./network.nix
    ./hardware.nix
    "${inputs.my-secrets}/hosts/bjs-ali-01/caddy.nix"
    "${inputs.my-secrets}/hosts/bjs-ali-01/proxy.nix"
  ];

  # Alibaba Beijing 2C-2G-40G

  # Infrastructure
  security'.firewall.enable = true;
  services'.openssh.enable = true;
  services'.vnstat.enable = true;

  # Application
  services'.caddy.enable = true;
  services'.tang.enable = true;

  # Container
  services'.docker.enable = true;

  # Database
  services'.postgresql.enable = true;
  services'.postgresql.openFirewall = true;

  # Proxy
  services'.dae.enable = true;
  services'.snell-server.enable = true;
}
