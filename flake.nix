{
  description = "Aaron's NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    my-secrets = {
      url = "git+ssh://git@github.com/27Aaron/nix-secrets.git?shallow=1";
      flake = false;
    };

    nur-aaron = {
      url = "git+https://codeberg.org/niceboy/nur-packages.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mimotion = {
      url = "github:27Aaron/mimotion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    inherit (nixpkgs) lib;
    forEachSystem = lib.genAttrs lib.systems.flakeExposed;
  in {
    nixosModules = import ./modules {inherit lib;};
    nixosConfigurations = import ./hosts {inherit self inputs lib;};

    # nix code formatter
    formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
