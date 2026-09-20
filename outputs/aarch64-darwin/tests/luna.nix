{
  assertions,
  configurations,
  ...
}:
assertions.checkAttrs {
  hostName = "luna";
  config = configurations.darwinConfigurations.luna.config;
  expectations = {
    "programs'.homebrew.enable" = true;
    "core'.touch-id.enable" = true;
    "development'.dev.enable" = true;
  };
}
