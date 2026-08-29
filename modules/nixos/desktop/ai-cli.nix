{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop'.apps.ai-cli;
in {
  options.desktop'.apps.ai-cli.enable = lib.mkEnableOption "AI coding CLIs (Claude Code and Codex)";

  config = lib.mkIf cfg.enable {
    hm'.home.packages = with pkgs; [
      claude-code
      codex
    ];

    hm'.home.shellAliases = {
      cc = "claude --dangerously-skip-permissions";
      cx = "codex --dangerously-bypass-approvals-and-sandbox";
    };

    preservation'.user = {
      directories = [
        ".claude"
        ".codex"
      ];

      files = [
        {
          file = ".claude.json";
          how = "bindmount";
        }
      ];
    };
  };
}
