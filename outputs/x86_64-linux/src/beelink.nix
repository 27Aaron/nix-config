{ mkHost, ... }:
{
  nixosConfigurations.beelink = mkHost "beelink";
}
