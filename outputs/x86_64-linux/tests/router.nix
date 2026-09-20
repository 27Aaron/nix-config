{
  assertions,
  configurations,
  ...
}:
assertions.checkAttrs {
  hostName = "router";
  config = configurations.nixosConfigurations.router.config;
  expectations = {
    # Server role: no desktop stack and no user tool suites.
    "desktop'.greetd.enable" = false;
    "desktop'.niri.enable" = false;
    "development'.ai.enable" = false;
    "development'.dev.enable" = false;
  };
}
