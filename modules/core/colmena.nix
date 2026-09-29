# Remote deployment metadata for colmena (see the `deploy` recipes). The colmena
# module provides deployment.*; hosts only set their own tags, and
# allowLocalDeployment enables `colmena apply-local` from the host's checkout.
{
  hostName,
  myvars,
  inputs,
  ...
}:
{
  imports = [ inputs.colmena.nixosModules.deploymentOptions ];

  deployment = {
    allowLocalDeployment = true;
    targetHost = hostName;
    targetPort = myvars.port.openssh;
    targetUser = "root";
  };
}
