# Flake checks: formatting, dead code, and host evaluation (`just check` runs
# them locally; the repository has no remote CI).
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
    # `nix flake check` does not force darwinConfigurations, the per-host
    # invariants or the colmena hive, so force all three. drvPath context is
    # discarded: this must only force evaluation, not pull in build closures.
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
