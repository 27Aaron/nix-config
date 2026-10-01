{
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        if test -x /opt/homebrew/bin/brew
          eval (/opt/homebrew/bin/brew shellenv fish)
        else if test -x /usr/local/bin/brew
          eval (/usr/local/bin/brew shellenv fish)
        end

        set -g fish_greeting

        if command -q uv
          uv generate-shell-completion fish | source
        end

        if command -q uvx
          uvx --generate-shell-completion fish | source
        end
      '';
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      initContent = ''
        if [ -x /opt/homebrew/bin/brew ]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -x /usr/local/bin/brew ]; then
          eval "$(/usr/local/bin/brew shellenv)"
        fi

        if command -v uv &>/dev/null; then
          eval "$(uv generate-shell-completion zsh)"
        fi

        if command -v uvx &>/dev/null; then
          eval "$(uvx generate-shell-completion zsh)"
        fi
      '';
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
      settings = {
        sync_frequency = 0;
        inline_height = 30;
        history_filter = [
          ''^\s+''
          ''^ls($|(\s+((-([a-zA-Z0-9]|-)+)|"(\.|[^/])[^"]*"|'(\.|[^/])*'|(\.|[^/\s-])[^\s]*))*\s*$)''
          ''^cd($|\s+('[^/][^']*'|"[^/][^"]*"|[^/\s'"][^\s]*))$''
          "/nix/store/.*"
          ''--cookie[=\s]+.+''
        ];
      };
    };
  };

  home.shellAliases = {
    cc = "claude --dangerously-skip-permissions";
    cx = "codex --dangerously-bypass-approvals-and-sandbox";
    ll = "eza -lah";
    gs = "git status";
  };
}
