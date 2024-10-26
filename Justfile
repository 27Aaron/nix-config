update:
    sudo nix flake update

nixos:
    sudo nixos-rebuild --flake .# switch 

darwin:
    nix run nix-darwin -- switch --flake .#