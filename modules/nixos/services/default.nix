{ ... }:
{
  imports = [
    ./fail2ban.nix
    ./openssh.nix
    ./vnstat.nix
    ./zram.nix
  ];
}
