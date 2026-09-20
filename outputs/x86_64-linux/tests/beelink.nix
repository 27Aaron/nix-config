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
    "services'.openssh.port" = port.openssh;
    "core'.firewall.enable" = true;
    "development'.ai.enable" = true;
  };
}
