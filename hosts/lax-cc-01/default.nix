{inputs, ...}: {
  imports = [
    ./network.nix
    ./hardware.nix
    "${inputs.my-secrets}/network/lax-cc-01/services.nix"
  ];

  # LAX CloudCone 1C-0.5G-40G

  # Infrastructure
  security'.firewall.enable = true;
  services'.openssh.enable = true;
  services'.fail2ban.enable = true;
  services'.vnstat.enable = true;

  # Application stack
  services'.postgresql.enable = true;
  services'.forgejo.enable = true;
  services'.caddy.enable = true;
}
