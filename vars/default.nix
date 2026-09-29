# User metadata and shared constants injected into hosts and Home Manager.
rec {
  username = "aaron";
  fullName = "Aaron";
  email = "niceboy@duck.com";

  timeZone = "Asia/Singapore";

  hashedPassword = "$y$j9T$fXIHIyb1usprTzAw.ntqJ/$I/sbwudS.KESDGLwKV8QzsLqr7pNQvYYv20GcWKFsV1";

  sshAuthorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA6xNNhF6jaPKuch8vSHwHTGlbyn4i2zSHxrqGOiacxG Aaron@Deployment"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHjMAQUXfyMv8TG1NfqjmQJG3gqZkh25KAvAMvxVrWS Aaron@MacBook-Pro"
  ];

  nix = {
    substituters = [
      "https://cache.numtide.com"
      "https://attic.xuyh0120.win/lantian"
    ];
    trustedPublicKeys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtQDxNNthLQETkc/yaX7M4qK0g="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
  };

  path = {
    homeDirectory = "/home/${username}";
    nixConfigDir = "nix-config";
    nixConfig = "${path.homeDirectory}/${path.nixConfigDir}";
  };

  port = {
    initrdSsh = 22;
    resolved = 53;
    openssh = 233;
    avahi = 5353;
  };
}
