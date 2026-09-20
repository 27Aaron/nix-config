{ mkHost, ... }:
{
  nixosConfigurations.router = mkHost "router";
}
