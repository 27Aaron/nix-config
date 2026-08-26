{
  preservation'.os.directories = [
    # AccountsService
    {
      directory = "/var/lib/AccountsService";
      mode = "0775";
    }

    # Bluetooth
    {
      directory = "/var/lib/bluetooth";
      mode = "0700";
    }

    # Containers
    {
      directory = "/var/lib/machines";
      mode = "0700";
    }

    # NetworkManager
    {
      directory = "/etc/NetworkManager/system-connections";
      mode = "0700";
    }
    "/var/lib/NetworkManager"

    # NixOS
    {
      directory = "/var/lib/nixos";
      inInitrd = true;
    }

    # OpenSSH
    "/etc/ssh"

    # Printing
    {
      directory = "/var/cache/cups";
      group = "lp";
      mode = "0770";
    }
    {
      directory = "/var/lib/cups";
      user = "cups";
      group = "lp";
    }
    {
      directory = "/var/spool/cups";
      group = "lp";
      mode = "0710";
    }

    # Private service state
    {
      directory = "/var/lib/private";
      mode = "0700";
    }

    # Power management
    "/var/lib/power-profiles-daemon"
    "/var/lib/upower"

    # Storage health monitoring
    {
      directory = "/var/lib/smartmontools";
      mode = "0750";
    }

    # System state and logs
    "/var/lib/lastlog"
    "/var/lib/nftables"
    "/var/lib/systemd"
    "/var/log"

    # Manual-page cache
    {
      directory = "/var/cache/man";
      user = "mandb";
      group = "mandb";
    }

    # Tuigreet
    {
      directory = "/var/cache/tuigreet";
      user = "greeter";
      group = "greeter";
    }

    # Files expected to survive reboots, unlike /tmp
    {
      directory = "/var/tmp";
      mode = "1777";
    }

    # vnStat
    {
      directory = "/var/lib/vnstat";
      user = "vnstatd";
      group = "vnstatd";
    }
  ];
}
