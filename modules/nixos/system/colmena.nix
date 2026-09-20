# Remote deployment metadata for colmena (see the `deploy` recipes).
#
# The deployment.* options come from colmena's NixOS module; hosts only
# declare their own tags, everything else is derived from the shared
# registries. allowLocalDeployment lets a host deploy itself from its own
# checkout with `colmena apply-local`.
{
  helpers,
  hostName,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.colmena.nixosModules.deploymentOptions ];

  deployment = {
    allowLocalDeployment = lib.mkDefault true;
    targetHost = lib.mkDefault hostName;
    targetPort = lib.mkDefault helpers.port.openssh;
    targetUser = lib.mkDefault "root";
  };
}
