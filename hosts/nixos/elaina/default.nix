{...}: {
  imports = [
    ./hardware.nix
  ];

  services' = {
    btrbk.enable = true;
    btrfs-scrub.enable = true;
    networkmanager.enable = true;
    openssh.enable = true;
    printing.enable = true;
    smartd.enable = true;
    upower.enable = true;
    vnstat.enable = true;
    zram.enable = true;
  };

  desktop' = {
    applications.enable = true;
    apps = {
      firefox.enable = true;
      kitty.enable = true;
      telegram.enable = true;
      vscode.enable = true;
    };
    cursors.enable = true;
    dms.enable = true;
    fcitx5.enable = true;
    fonts.enable = true;
    greetd.enable = true;
    niri.enable = true;
    themes.enable = true;
  };

  security.rtkit.enable = true;
  security'.firewall.enable = true;

  system.stateVersion = "26.11";
}
