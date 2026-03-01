# List all available commands
list:
    @just --list

# Build and switch to current configuration
switch:
    @sudo nixos-rebuild --flake .# switch

# Build and switch with sandbox disabled
switch-no-sandbox:
    @sudo nixos-rebuild --flake .# switch --option sandbox false

# Deploy to remote host
switch-remote host:
    @nixos-rebuild --flake ".#{{ host }}" switch --target-host "root@{{ host }}" -v

# Build and switch using SJTU mirror
switch-sjtu:
    @sudo nixos-rebuild --flake .# switch --option substituters "https://mirror.sjtu.edu.cn/nix-channels/store"

# Check flake syntax
check:
    @nix flake check

# Update flake lock file
update:
    @nix flake update

# View system profile history
history:
    @nix profile history --profile /nix/var/nix/profiles/system

# Clean profile history older than 3 days
clean:
    @sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 3d

# Garbage collect unused store paths
gc:
    @sudo nix store gc --debug
    @sudo nix-collect-garbage --delete-old
