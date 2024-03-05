{inputs, ...}: {
  imports = [
    ./network.nix
    ./hardware.nix
    "${inputs.my-secrets}/network/nrt-gc-01/proxy.nix"
  ];

  # GreenCloud SoftBank 6C-12G-112G
  services'.vnstat.enable = true;
  services'.openssh.enable = true;
  security'.firewall.enable = true;

  services'.snell-server.enable = true;
  services'.sing-box.enable = true;
}
