{pkgs, ...}: {
  home.packages = with pkgs; [
    claude-code
    codex
  ];

  home.shellAliases = {
    cc = "claude --dangerously-skip-permissions";
    cx = "codex --dangerously-bypass-approvals-and-sandbox";
  };
}
