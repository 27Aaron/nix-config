{
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  programs.vscode = lib.mkIf osConfig.desktop'.apps.vscode.enable {
    enable = true;

    # Nixpkgs restores this integrity-sensitive binary after fixup, but the copy
    # loses its executable bit, so verification fails with EACCES.
    package = pkgs.vscode.overrideAttrs (oldAttrs: {
      postFixup = (oldAttrs.postFixup or "") + ''
        chmod +x "$out/lib/vscode/resources/app/node_modules/@vscode/vsce-sign/bin/vsce-sign"
      '';
    });
  };
}
