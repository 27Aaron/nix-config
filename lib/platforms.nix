{
  inputs,
  myvars,
}: {
  darwin = {
    builder = inputs.nix-darwin.lib.darwinSystem;
    homeManagerModule = inputs.home-manager.darwinModules.home-manager;
    modulesPath = ../modules/darwin;
    homeModulesPath = ../home/darwin;
    homeDirectory = "/Users/${myvars.username}";
  };

  nixos = {
    builder = inputs.nixpkgs.lib.nixosSystem;
    homeManagerModule = inputs.home-manager.nixosModules.home-manager;
    modulesPath = ../modules/nixos;
    homeModulesPath = ../home/nixos;
    homeDirectory = "/home/${myvars.username}";
  };
}
