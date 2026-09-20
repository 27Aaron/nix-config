# Flake checks: formatting, dead code, and host evaluation.
#
# `just check` evaluates these locally; the repository has no remote CI.
{
  self,
  nixpkgs,
  configurations,
  colmenaHive,
  evalTestFailures,
  systemNames,
}:
let
  inherit (nixpkgs) lib;
  forEachSystem = lib.genAttrs systemNames;
in
forEachSystem (
  system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    format = pkgs.runCommand "check-format" { nativeBuildInputs = [ pkgs.nixfmt-rs ]; } ''
      nixfmt --check ${self}
      touch $out
    '';

    deadnix = pkgs.runCommand "check-deadnix" { nativeBuildInputs = [ pkgs.deadnix ]; } ''
      deadnix --fail ${self}
      touch $out
    '';
  }
  // lib.optionalAttrs (lib.hasSuffix "-darwin" system) {
    # `nix flake check` evaluates nixosConfigurations deeply but does not
    # force-evaluate darwinConfigurations, the per-host invariants
    # (outputs/<system>/tests/) or the colmena hive (a non-standard flake
    # output, so only a warning), so force all three here. drvPath strings
    # carry context, so discard it: the check should only force evaluation,
    # not depend on each host's build closure.
    eval = pkgs.runCommand "check-eval" {
      drvPaths = lib.concatStringsSep " " (
        lib.mapAttrsToList (
          _: host: lib.unsafeDiscardStringContext host.system.drvPath
        ) configurations.darwinConfigurations
      );
      hosts =
        if evalTestFailures == [ ] then
          "ok"
        else
          throw "host assertion failures:\n${lib.concatStringsSep "\n" evalTestFailures}";
      hive = builtins.toJSON {
        inherit (colmenaHive) __schema deploymentConfig;
      };
    } "touch $out";
  }
)
