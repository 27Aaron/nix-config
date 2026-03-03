{pkgs, ...}: {
  hm'.home.packages = with pkgs; [
    # Archive tools
    p7zip # 7z compression
    unzipNLS # unzip with NLS support
    xz # XZ compression
    zip # ZIP compression
    zstd # Zstandard compression

    # CLI tools
    fd # Faster find alternative
    fzf # Command-line fuzzy finder

    # Development tools
    alejandra # Nix formatter
    just # Command runner
    lazygit # Git TUI

    # Disk & file analysis
    duf # Disk usage (colorful & intuitive)
    dust # du alternative (more intuitive)
    ncdu # Disk usage (interactive cleanup)

    # Monitoring tools
    bottom # Process monitor (cross-platform)
    btop # Resource monitor (htop++)
    fastfetch # System info fetcher
    gping # Graphical ping
    htop # Process monitor
    iotop # I/O monitor
    nload # Network load monitor
    sysstat # System performance tools
    tailspin # tail -f enhanced

    # Network tools
    ipcalc # IP calculator
    iperf3 # Network performance tester
    mtr # traceroute + ping combo
    nmap # Port scanner
    socat # Multipurpose data relay
    tcpdump # Packet capture

    # Text processing
    gawk # awk
    gnugrep # grep
    gnused # sed
    jq # JSON processor

    # Utils
    lsof # List open files
    psmisc # Process utilities (pstree, killall...)
    which # Locate a command
  ];

  environment.systemPackages = with pkgs; [
    # Basics
    curl # Data transfer tool
    git # Version control
    git-lfs # Git large file storage
    openssl # SSL/TLS toolkit
    rsync # File synchronization
    wget # Network downloader

    # System-level diagnostics
    bpftrace # eBPF tracer
    dnsutils # DNS tools (dig, nslookup)
    iftop # Network bandwidth monitor
    strace # System call tracer
  ];
}
