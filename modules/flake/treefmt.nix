# Unified formatting: `nix fmt` runs treefmt over every file type declared
# here, and `nix flake check` validates formatting.
{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      treefmt.programs = {
        nixfmt = {
          enable = true;
          package = pkgs.nixfmt-rs;
        };
        prettier.enable = true;
      };
    };
}
