# Light-weight eval tests: frozen per-host invariants.
#
# Each entry pins a host role or a value that is easy to break when shared
# modules change (e.g. a server accidentally gaining the desktop stack).
# Update the expectations deliberately when the behavior is meant to change;
# lib/checks.nix turns any mismatch into a failed flake check.
{
  lib,
  configurations,
}:
let
  expectations = {
    darwinConfigurations = {
      luna = {
        "apps'.homebrew.enable" = true;
        "security'.touch-id.enable" = true;
        "tools'.dev.enable" = true;
      };
    };

    nixosConfigurations = {
      elaina = {
        "desktop'.niri.enable" = true;
        "desktop'.niri.autoLogin" = true;
        "services'.openssh.port" = 233;
        "security'.firewall.enable" = true;
        "tools'.ai.enable" = true;
      };

      beelink = {
        "desktop'.apps.zed.enable" = true;
        "desktop'.niri.enable" = true;
        "services'.openssh.port" = 233;
        "security'.firewall.enable" = true;
        "tools'.ai.enable" = true;
      };

      router = {
        # Server role: no desktop stack and no user tool suites.
        "desktop'.greetd.enable" = false;
        "desktop'.niri.enable" = false;
        "tools'.ai.enable" = false;
        "tools'.dev.enable" = false;
        "nix.settings.max-jobs" = 1;
        "services'.openssh.port" = 233;
        "security'.firewall.enable" = true;
      };
    };
  };

  checkHost =
    configurationsAttr: host: checks:
    lib.mapAttrsToList (
      path: expected:
      let
        actual = lib.attrByPath (lib.splitString "." path) null configurationsAttr.${host}.config;
      in
      if actual == expected then
        null
      else
        "${host}: ${path} = ${builtins.toJSON actual}, expected ${builtins.toJSON expected}"
    ) checks;
in
lib.filter (x: x != null) (
  lib.flatten (
    lib.mapAttrsToList (
      attrName: hosts:
      lib.mapAttrsToList (host: checks: checkHost configurations.${attrName} host checks) hosts
    ) expectations
  )
)
