{
  imports = [
    ./network.nix
    ./hardware.nix
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
  services'.forgejo.domain = "code.niceboy.org";
  services'.caddy.enable = true;
}
