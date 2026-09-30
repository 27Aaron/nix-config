# Host discovery: every `hosts/<category>/<name>/default.nix` is a host.
{ lib, ... }:
let
  myvars = import ../../vars;
  hostsDir = ../../hosts;

  hostDirs = lib.concatMapAttrs (
    category: _:
    lib.mapAttrs (name: _: hostsDir + "/${category}/${name}") (
      lib.filterAttrs (
        name: type:
        type == "directory" && builtins.pathExists (hostsDir + "/${category}/${name}/default.nix")
      ) (builtins.readDir (hostsDir + "/${category}"))
    )
  ) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir hostsDir));

  hosts = lib.mapAttrs (
    name: dir:
    let
      host = import (dir + "/default.nix") { inherit lib; };
      category = baseNameOf (dirOf dir);
    in
    assert lib.assertMsg (
      (host.name or name) == name
    ) "Host ${host.name} must live in hosts/${category}/${host.name}";
    host
    // {
      inherit name category;
      class = host.class or (if category == "darwin" then "darwin" else "nixos");
    }
  ) hostDirs;
in
{
  # The macOS development machine keeps per-system outputs (formatter, checks)
  # available before the Mac hosts land here.
  systems = lib.unique ([ "aarch64-darwin" ] ++ lib.mapAttrsToList (_: host: host.system) hosts);

  _module.args = { inherit hosts myvars; };
}
