{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop'.apps.vscode;
in {
  options.desktop'.apps.vscode.enable = lib.mkEnableOption "Visual Studio Code";

  config = lib.mkIf cfg.enable {
    hm'.programs.vscode = {
      enable = true;

      # Nixpkgs restores this integrity-sensitive binary after fixup, but the
      # copied file loses its executable bit and extension verification fails
      # with EACCES before the verifier can run.
      package = pkgs.vscode.overrideAttrs (oldAttrs: {
        postFixup =
          (oldAttrs.postFixup or "")
          + ''
            chmod +x "$out/lib/vscode/resources/app/node_modules/@vscode/vsce-sign/bin/vsce-sign"
          '';
      });
    };

    preservation'.user.directories = [
      # Visual Studio Code
      ".config/Code"
      ".vscode"
      ".vscode-shared"
    ];
  };
}
