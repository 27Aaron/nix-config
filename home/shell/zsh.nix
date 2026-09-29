{
  programs.zsh = {
    enable = true;
    initContent = ''
      # Load uv and uvx completions when the development toolset is installed.
      if command -v uv &>/dev/null; then
        eval "$(uv generate-shell-completion zsh)"
      fi

      if command -v uvx &>/dev/null; then
        eval "$(uvx --generate-shell-completion zsh)"
      fi
    '';
  };
}
