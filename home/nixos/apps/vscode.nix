{pkgs, ...}: {
  programs.vscode = {
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
}
