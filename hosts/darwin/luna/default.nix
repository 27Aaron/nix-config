{
  system = "aarch64-darwin";

  specialArgs = {
    username = "aaron";
    fullName = "Aaron";
    email = "niceboy@duck.com";
    timeZone = "Asia/Singapore";
  };

  modules = [ ./configuration.nix ];
}
