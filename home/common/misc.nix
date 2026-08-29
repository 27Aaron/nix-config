{
  lib,
  pkgs,
  ...
}: {
  home.packages = lib.mkAfter (with pkgs; [
    # Development
    just

    # Disk & Cleanup
    duf
    dust

    # File & Search
    fd
    fzf
    jq
    ripgrep
    wget

    # Network
    iperf3
    nmap
    socat

    # System Monitor
    btop
    fastfetch
    nload
  ]);
}
