{
  assertions,
  configurations,
  port,
  ...
}:
assertions.checkAttrs {
  hostName = "elaina";
  config = configurations.nixosConfigurations.elaina.config;
  expectations = {
    "desktop'.niri.enable" = true;
    "desktop'.niri.autoLogin" = true;
    "services.openssh.ports" = [ port.openssh ];
    "core'.firewall.enable" = true;
    "development'.ai.enable" = true;
  };
}
