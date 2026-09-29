{ ... }:
{
  services'.fail2ban.enable = true;
  services'.openssh.enable = true;
  services'.vnstat.enable = true;
  services'.zram.enable = true;
}
