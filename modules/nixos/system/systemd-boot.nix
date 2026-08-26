{lib, ...}: {
  boot.loader.systemd-boot = {
    editor = lib.mkDefault false;
    consoleMode = lib.mkDefault "max";
    configurationLimit = lib.mkDefault 8;
  };
}
