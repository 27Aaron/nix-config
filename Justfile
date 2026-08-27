hostname := `hostname -s`

# List all the just commands
default:
    @just --list

# Check formatting, unused declarations, and all host configurations locally
check:
    @alejandra --check .
    @deadnix --fail .
    @nix flake check path:. --no-build --all-systems
    @nix eval path:.#darwinConfigurations --json --apply 'builtins.mapAttrs (_: host: host.system.drvPath)' >/dev/null

# Build and activate the nix-darwin configuration
[macos]
switch:
    @sudo darwin-rebuild --flake path:.#{{ hostname }} switch

# Build and activate the NixOS configuration
[linux]
switch:
    @nh os switch path:. -H {{ hostname }}

# Update the flake inputs (nixpkgs, nix-darwin, etc.)
update:
    @nix flake update

# Delete macOS generations and collect unreachable store paths older than 7 days
[macos]
gc:
    @sudo nix-collect-garbage --delete-older-than 7d

# Review and clean NixOS generations, GC roots, and unreachable store paths
[linux]
gc:
    @nh clean all --keep 8 --keep-since 14d --ask

# Install nix-darwin on a fresh macOS system
[macos]
install:
    @sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake path:.#{{ hostname }}

# Format all Nix files in the flake
fmt:
    @nix fmt path:.
