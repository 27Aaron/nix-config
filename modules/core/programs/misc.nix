{pkgs, ...}: {
  hm'.home.packages = with pkgs; [
    # Archive
    p7zip
    unzipNLS
    xz
    zip
    zstd

    # CLI
    just

    # Disk
    ncdu

    # Monitor
    btop
    htop
    iotop
    nload
    sysstat
    fastfetch

    # Network
    iperf3
    mtr
    nmap
    socat
    tcpdump

    # Process
    lsof
    psmisc

    # Text
    gawk
    gnugrep
    gnused
    jq

    # Utils
    which
  ];

  environment.systemPackages = with pkgs; [
    # Basics
    curl
    git
    git-lfs
    lazygit
    openssl
    rsync
    wget

    # Network
    dnsutils
    iftop
  ];
}
