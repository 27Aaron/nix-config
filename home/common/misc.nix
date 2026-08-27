{
  lib,
  pkgs,
  ...
}: {
  home.packages = lib.mkAfter (with pkgs; [
    # Development
    codex
    claude-code
    gh
    just
    lazygit
    uv

    # Disk & Cleanup
    duf
    dust
    ncdu

    # File & Search
    fd
    fzf
    jq
    ripgrep
    tree
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
    htop
    nload
  ]);

  # AI assistants
  persist'.directories = [
    ".codex"
    ".claude"
  ];

  persist'.files = [
    {
      file = ".claude.json";
      how = "bindmount";
    }
  ];
}
