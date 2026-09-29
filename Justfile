hostname := `hostname -s`

# List all the just commands
default:
    @just --list

# Check formatting, unused declarations, and all host configurations locally
check:
    @nix fmt . -- --check
    @prettier --check '**/*.md'
    @deadnix --fail .
    @nix flake check path:. --no-build --all-systems

# Build and activate the NixOS configuration
[linux]
switch:
    @nh os switch path:. -H {{ hostname }}

# Deploy NixOS hosts via colmena, building locally (run this on a Linux host)
deploy on="@homelab" mode="switch":
    @colmena apply {{mode}} --on '{{on}}'

# Deploy while building closures on the target hosts.
deploy-target on="@homelab" mode="switch":
    @colmena apply {{mode}} --build-on-target --on '{{on}}'

# Update the flake inputs
update:
    @nix flake update

# Review and clean generations, GC roots, and unreachable store paths
gc:
    @nh clean all --keep 8 --keep-since 14d --ask

# Format all Nix files in the flake
fmt:
    @nix fmt .
