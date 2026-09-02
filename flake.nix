{
  description = "Aaron's Nix configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    llm-agents.url = "github:numtide/llm-agents.nix";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/27Aaron/nix-secrets.git?shallow=1";
      flake = false;
    };

    nur-aaron = {
      url = "github:27Aaron/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {nixpkgs, ...}: let
    inherit (nixpkgs) lib;

    myvars = import ./vars;
    configurations = import ./hosts {inherit inputs myvars;};

    supportedSystems = [
      "aarch64-darwin"
      "x86_64-linux"
    ];
    forEachSystem = lib.genAttrs supportedSystems;
  in
    configurations
    // {
      darwinModules.default = import ./modules "darwin";
      nixosModules.default = import ./modules "nixos";

      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.alejandra);
    };
}
