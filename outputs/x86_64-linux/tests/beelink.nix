{
  assertions,
  configurations,
  port,
  ...
}:
assertions.checkAttrs {
  hostName = "beelink";
  config = configurations.nixosConfigurations.beelink.config;
  expectations = {
    "desktop'.apps.zed.enable" = true;
    "desktop'.niri.enable" = true;
    "services.openssh.ports" = [ port.openssh ];
    "core'.firewall.enable" = true;
    "development'.ai.enable" = true;
  };
}
