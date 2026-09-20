{ lib }:
rec {
  # Recursively collect importable module paths under a directory.
  #
  # A subdirectory that contains a default.nix is imported as a single module;
  # any other subdirectory is scanned recursively. Plain .nix files are
  # collected directly. A missing directory contributes nothing, so a
  # platform can have no platform-specific home modules.
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
