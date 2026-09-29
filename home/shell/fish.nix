{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Disable the greeting message.
      set -g fish_greeting

      # Load uv and uvx completions when the development toolset is installed.
      if command -q uv
        uv generate-shell-completion fish | source
      end

      if command -q uvx
        uvx --generate-shell-completion fish | source
      end
    '';
  };
}
