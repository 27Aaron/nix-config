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
    "security'.firewall.enable" = true;
    "tools'.ai.enable" = true;
  };
}
