{
  assertions,
  configurations,
  ...
}:
assertions.checkAttrs {
  hostName = "luna";
  config = configurations.darwinConfigurations.luna.config;
  expectations = {
    "apps'.homebrew.enable" = true;
    "security'.touch-id.enable" = true;
    "tools'.dev.enable" = true;
  };
}
