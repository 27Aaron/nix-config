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
    "development'.dev.enable" = true;
  };
}
