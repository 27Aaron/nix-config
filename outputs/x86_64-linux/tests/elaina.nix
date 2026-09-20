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
    "services'.openssh.port" = port.openssh;
    "security'.firewall.enable" = true;
    "tools'.ai.enable" = true;
  };
}
