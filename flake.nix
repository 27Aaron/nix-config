{
  description = "Aaron's NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    preservation.url = "github:nix-community/preservation";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      forEachSystem = lib.genAttrs lib.systems.flakeExposed;
    in
    {
      nixosModules = import ./modules { inherit lib; };
      nixosConfigurations = import ./hosts { inherit self inputs lib; };

      # nix code formatter
      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
