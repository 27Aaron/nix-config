hostname := `hostname -s`

# List all the just commands
default:
    @just --list

# Check formatting, unused declarations, and all host configurations locally
check:
    @nix fmt . -- --check
    @deadnix --fail .
    @nix flake check path:. --no-build --all-systems

# Build and activate the nix-darwin configuration
[macos]
switch:
    @nh darwin switch path:. -H {{ hostname }}

# Build and activate the NixOS configuration
[linux]
switch:
    @nh os switch path:. -H {{ hostname }}

# Deploy NixOS hosts via colmena, building locally (run this on a Linux host)
deploy on="@homelab" mode="switch":
    @colmena apply {{mode}} --on '{{on}}'

# Same as deploy, but builds on the target hosts (for running from macOS)
deploy-mac on="@homelab" mode="switch":
    @colmena apply {{mode}} --build-on-target --on '{{on}}'

# Update the flake inputs (nixpkgs, nix-darwin, etc.)
update:
    @nix flake update

# Review and clean generations, GC roots, and unreachable store paths
gc:
    @nh clean all --keep 8 --keep-since 14d --ask

# Install nix-darwin on a fresh macOS system
[macos]
install:
    @sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake path:.#{{ hostname }}

# Format all Nix files in the flake
fmt:
    @nix fmt .
