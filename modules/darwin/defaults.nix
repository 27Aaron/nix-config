{ config, ... }:
{
  # Unlock sudo with Touch ID.
  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    smb.NetBIOSName = config.networking.hostName;

    # Menu bar clock.
    menuExtraClock = {
      Show24Hour = true;
      ShowSeconds = true;
    };

    # Dock and hot corners.
    dock = {
      autohide = true;
      show-recents = false;
      wvous-bl-corner = 3;
      wvous-br-corner = 13;
      wvous-tl-corner = 2;
      wvous-tr-corner = 4;
    };

    # Finder behavior and desktop visibility.
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      FXDefaultSearchScope = "SCcf";
      NewWindowTarget = "Home";
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
    };

    # Window management and Stage Manager.
    WindowManager = {
      EnableStandardClickToShowDesktop = false;
      HideDesktop = false;
      StageManagerHideWidgets = false;
      StandardHideDesktopIcons = false;
      StandardHideWidgets = false;
    };

    # Lock screen and screenshot defaults.
    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 0;
    };

    screencapture = {
      location = "~/Desktop";
      type = "png";
    };

    # Spaces and keyboard behavior.
    spaces.spans-displays = false;

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      InitialKeyRepeat = 15;
      KeyRepeat = 3;
      AppleKeyboardUIMode = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      "com.apple.sound.beep.feedback" = 0;
      "com.apple.swipescrolldirection" = true;
    };

    # Preferences without dedicated nix-darwin options.
    CustomUserPreferences = {
      ".GlobalPreferences" = {
        AppleSpacesSwitchOnActivate = true;
      };

      NSGlobalDomain = {
        WebKitDeveloperExtras = true;
      };

      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };

      "com.apple.ImageCapture".disableHotPlug = true;

      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
  };
}
