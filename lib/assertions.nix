# Assertion helper for the light-weight eval tests under
# outputs/<system>/tests/.
#
# Each test file pins the frozen invariants of one host: a host role or a
# value that is easy to break when shared modules change (e.g. a server
# accidentally gaining the desktop stack). Values that live in the shared
# registries (the SSH port) are referenced instead of frozen, so a registry
# change flows through the expectations. Update the rest deliberately when
# the behavior is meant to change; outputs/checks.nix turns any mismatch
# into a failed flake check.
{ lib }:
{
  # Compare a host's evaluated config against expected attribute values.
  # Returns a list of failure messages; empty when every expectation holds.
  checkAttrs =
    {
      hostName,
      config,
      expectations,
    }:
    lib.filter (message: message != null) (
      lib.mapAttrsToList (
        path: expected:
        let
          actual = lib.attrByPath (lib.splitString "." path) null config;
        in
        if actual == expected then
          null
        else
          "${hostName}: ${path} = ${builtins.toJSON actual}, expected ${builtins.toJSON expected}"
      ) expectations
    );
}
