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

  # State for the tools installed above.
  persist'.directories = [
    # GitHub CLI account settings and fallback credentials.
    {
      directory = ".config/gh";
      mode = "0700";
    }

    # AI assistants
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
