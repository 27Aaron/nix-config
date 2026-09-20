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

    # Media
    ffmpeg

    # Network
    iperf3
    nmap
    socat

    # System Monitor
    btop
    fastfetch
    nload
  ];

  # btop rewrites its config when settings change from the UI.
  persist'.directories = [
    ".config/btop"
  ];
}
