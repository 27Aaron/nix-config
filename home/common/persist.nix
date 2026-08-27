# Bridge for pure Home Manager tools: they cannot write NixOS-side
# preservation options directly, so they report their state here and the
# storage persistence module splices it into preservation'.
{lib, ...}: {
  options.persist' = {
    directories = lib.mkOption {
      type = lib.types.listOf (
        lib.types.either lib.types.str (lib.types.attrsOf lib.types.raw)
      );
      default = [];
      description = ''
        State directories to preserve inside the user's home, in the same
        shape preservation accepts per-user directory entries.'';
    };

    files = lib.mkOption {
      type = lib.types.listOf (
        lib.types.either lib.types.str (lib.types.attrsOf lib.types.raw)
      );
      default = [];
      description = ''
        Files to preserve inside the user's home, in the same shape
        preservation accepts per-user file entries.'';
    };
  };
}
