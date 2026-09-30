{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
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
    nload

    # System Info
    fastfetch
  ];
}
