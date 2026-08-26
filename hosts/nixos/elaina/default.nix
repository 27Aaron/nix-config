{...}: {
  system.stateVersion = "26.11";

  storage'.persistence.enable = true;

  hm'.home'.apps = {
    firefox.enable = true;
    kitty.enable = true;
    telegram.enable = true;
    vscode.enable = true;
  };

  imports = [
    ./hardware.nix
  ];

  desktop' = {
    applications.enable = true;
    cursors.enable = true;
    dms.enable = true;
    fcitx5.enable = true;
    fonts.enable = true;
    niri.enable = true;
    themes.enable = true;
  };

  hardware'.amdgpu.enable = true;

  security.rtkit.enable = true;

  services' = {
    btrbk.enable = true;
    btrfs-scrub.enable = true;
    networkmanager.enable = true;
    openssh.enable = true;
    printing.enable = true;
    smartd.enable = true;
    vnstat.enable = true;
    zram.enable = true;
  };

  security'.firewall.enable = true;
}
