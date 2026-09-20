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
  ...
}:
{
  imports = [ inputs.colmena.nixosModules.deploymentOptions ];

  deployment = {
    allowLocalDeployment = true;
    targetHost = hostName;
    targetPort = helpers.port.openssh;
    targetUser = "root";
  };
}
