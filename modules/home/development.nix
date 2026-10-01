{ pkgs, ... }:
{
  programs.mise = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    globalConfig = {
      settings = {
        minimum_release_age = "24h";
        minimum_release_age_excludes = [ "npm:@deepseek-ai/dsh" ];
        npm.package_manager = "pnpm";
      };

      tools = {
        node = "22";
        pnpm = "latest";
        "npm:@anthropic-ai/claude-code" = "latest";
        "npm:@deepseek-ai/dsh" = {
          version = "latest";
          allow_low_downloads = true;
        };
        "npm:@openai/codex" = "latest";
      };
    };
  };

  home.packages = with pkgs; [
    prettier
    uv
  ];
}
