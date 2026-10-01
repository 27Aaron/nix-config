{
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
      '';
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        character = {
          success_symbol = "[›](bold green)";
          error_symbol = "[✗](bold red)";
        };
      };
    };

    eza = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    atuin = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      settings.sync_frequency = 0;
    };
  };

  home.shellAliases = {
    ll = "eza -lah";
    gs = "git status";
  };
}
