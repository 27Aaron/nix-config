{ lib }:
rec {
  # Recursively collect importable module paths under a directory: a subdirectory
  # with a default.nix is one module, others are scanned recursively; a missing
  # directory contributes nothing.
  scanPaths =
    directory:
    lib.pipe (if builtins.pathExists directory then builtins.readDir directory else { }) [
      (lib.mapAttrsToList (
        name: type:
        let
          path = directory + "/${name}";
          isNixDirectory = builtins.pathExists (path + "/default.nix");
          isNixFile = type == "regular" && lib.hasSuffix ".nix" name;
        in
        if type == "directory" then
          if isNixDirectory then [ path ] else scanPaths path
        else
          lib.optional isNixFile path
      ))
      lib.flatten
    ];
}
