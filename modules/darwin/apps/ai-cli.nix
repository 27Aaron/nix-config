{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.apps'.ai-cli;
in {
  options.apps'.ai-cli.enable = lib.mkEnableOption "AI coding CLIs (Claude Code and Codex)";

  config = lib.mkIf cfg.enable {
    hm'.home.packages = with pkgs; [
      claude-code
      codex
    ];

    hm'.home.shellAliases = {
      cc = "claude --dangerously-skip-permissions";
      cx = "codex --dangerously-bypass-approvals-and-sandbox";
    };
  };
}
