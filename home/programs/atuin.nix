{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      sync_frequency = 0;
      inline_height = 30;
      history_filter = [
        # filter commands with leading spaces
        ''^\s+''
        # filter ls command with non-absolute paths
        ''^ls($|(\s+((-([a-zA-Z0-9]|-)+)|"(\.|[^/])[^"]*"|'(\.|[^/])[^']*'|(\.|[^/\s-])[^\s]*))*\s*$)''
        # filter cd command with non-absolute paths
        ''^cd($|\s+('[^/][^']*'|"[^/][^"]*"|[^/\s'"][^\s]*))$''
        # command contains /nix/store
        "/nix/store/.*"
        # command contains cookie
        ''--cookie[=\s]+.+''
      ];
    };
  };

  persist'.directories = [
    {
      directory = ".atuin";
      mode = "0700";
    }
    ".local/share/atuin"
  ];
}
