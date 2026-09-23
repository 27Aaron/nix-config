{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop'.apps.vscode;
in
{
  options.desktop'.apps.vscode = {
    enable = lib.mkEnableOption "Visual Studio Code";
  };

  config = lib.mkIf cfg.enable {
    hm'.programs.vscode = {
      enable = true;

      # Nixpkgs restores this integrity-sensitive binary after fixup, but the copy
      # loses its executable bit, so verification fails with EACCES.
      package = pkgs.vscode.overrideAttrs (oldAttrs: {
        postFixup = (oldAttrs.postFixup or "") + ''
          chmod +x "$out/lib/vscode/resources/app/node_modules/@vscode/vsce-sign/bin/vsce-sign"
        '';
      });
    };

    preservation'.user.directories = [
      ".config/Code"
      ".vscode"
    ];
  };
}
