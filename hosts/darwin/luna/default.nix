{
  system = "aarch64-darwin";

  # Values shared with the host's system modules.
  specialArgs = {
    username = "aaron";
    fullName = "Aaron";
    email = "niceboy@duck.com";
    timeZone = "Asia/Singapore";
  };

  modules = [ ./configuration.nix ];
}
