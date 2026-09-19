{
  self,
  nixpkgs,
  configurations,
  supportedSystems,
}:
let
  inherit (nixpkgs) lib;
  forEachSystem = lib.genAttrs supportedSystems;

  # The port registry is platform-independent, so it can be read directly
  # without evaluating the per-host helpers.
  port = (import ../helpers/constants/ports.nix { inherit lib; }).port;

  evalTestFailures = import ./eval-tests.nix {
    inherit lib configurations port;
  };
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

    # Frozen per-host invariants (lib/eval-tests.nix): fail the check when
    # any expectation no longer holds.
    hosts-eval = pkgs.runCommand "check-hosts-eval" {
      result =
        if evalTestFailures == [ ] then
          "ok"
        else
          throw "host assertion failures:\n${lib.concatStringsSep "\n" evalTestFailures}";
    } "touch $out";
  }
)
