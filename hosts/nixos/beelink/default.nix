{...}: {
  imports = [
    ./hardware.nix
  ];

  services' = {
    coder = {
      enable = true;
      listenAddress = "0.0.0.0:34567";
      accessUrl = "https://coder.in.ou.al";
      wildcardAccessUrl = "*.coder.in.ou.al";
      openFirewall = true;
    };
    postgresql.enable = true;
    networkmanager.enable = true;
    openssh.enable = true;
    vnstat.enable = true;
    zram.enable = true;
  };

  security'.firewall.enable = true;

  tools'.dev.enable = true;

  system.stateVersion = "26.11";
}
