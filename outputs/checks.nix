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
    # nix flake check evaluates nixosConfigurations deeply but not
    # darwinConfigurations; force-evaluate every darwin host via env.
    # drvPath strings carry context, so discard it: the check should only
    # force evaluation, not depend on each host's build closure.
    darwin-eval = pkgs.runCommand "check-darwin-eval" {
      drvPaths = lib.concatStringsSep " " (
        lib.mapAttrsToList (
          _: host: lib.unsafeDiscardStringContext host.system.drvPath
        ) configurations.darwinConfigurations
      );
    } "touch $out";

    # Frozen per-host invariants (outputs/<system>/tests/): fail the check
    # when any expectation no longer holds.
    hosts-eval = pkgs.runCommand "check-hosts-eval" {
      result =
        if evalTestFailures == [ ] then
          "ok"
        else
          throw "host assertion failures:\n${lib.concatStringsSep "\n" evalTestFailures}";
    } "touch $out";

    # colmenaHive is not a standard flake output, so `nix flake check` only
    # warns about it; force-evaluate the hive (schema + per-host deployment
    # config) so a broken colmena integration fails the check.
    colmena-hive = pkgs.runCommand "check-colmena-hive" {
      hive = builtins.toJSON {
        inherit (colmenaHive) __schema deploymentConfig;
      };
    } "touch $out";
  }
)
