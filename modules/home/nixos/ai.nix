{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  enable = osConfig.development'.ai.enable;
in
{
  # Install the CLI packages only; leaving settings unmanaged keeps HM from
  # taking over the live files inside ~/.claude and ~/.codex.
  home.packages = lib.mkIf enable (
    with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    [
      chatgpt
      claude-code
      codex
      grok
    ]
  );

  home.shellAliases = lib.mkIf enable {
    cc = "claude --dangerously-skip-permissions";
    cx = "codex --dangerously-bypass-approvals-and-sandbox";
  };
}
