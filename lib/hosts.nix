{ lib }:
let
  findHostDirectories =
    root:
    let
      directories = lib.filterAttrs (_: type: type == "directory") (builtins.readDir root);
    in
    lib.concatLists (
      lib.mapAttrsToList (
        name: _:
        let
          path = root + "/${name}";
        in
        if builtins.pathExists (path + "/default.nix") then
          [ { inherit name path; } ]
        else
          findHostDirectories path
      ) directories
    );

  discover =
    root:
    let
      hosts = findHostDirectories root;
      names = map (host: host.name) hosts;
      uniqueNames = lib.unique names;
    in
    if builtins.length names != builtins.length uniqueNames then
      throw "duplicate host name discovered under ${toString root}"
    else
      lib.listToAttrs (
        map (
          { name, path }:
          lib.nameValuePair name (import (path + "/default.nix"))
        ) hosts
      );
in
{
  inherit discover;
}
