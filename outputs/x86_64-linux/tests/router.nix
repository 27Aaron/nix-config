{
  assertions,
  configurations,
  port,
  ...
}:
assertions.checkAttrs {
  hostName = "router";
  config = configurations.nixosConfigurations.router.config;
  expectations = {
    # Server role: no desktop stack and no user tool suites.
    "desktop'.greetd.enable" = false;
    "desktop'.niri.enable" = false;
    "tools'.ai.enable" = false;
    "tools'.dev.enable" = false;
    "nix.settings.max-jobs" = 1;
    "services'.openssh.port" = port.openssh;
    "security'.firewall.enable" = true;
  };
}
