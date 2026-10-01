{ ... }:
{
  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    menuExtraClock = {
      Show24Hour = true;
      ShowSeconds = true;
    };

    dock = {
      autohide = true;
      show-recents = false;
      wvous-bl-corner = 3;
      wvous-br-corner = 13;
      wvous-tl-corner = 2;
      wvous-tr-corner = 4;
    };

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

    WindowManager = {
      EnableStandardClickToShowDesktop = false;
      HideDesktop = false;
      StageManagerHideWidgets = false;
      StandardHideDesktopIcons = false;
      StandardHideWidgets = false;
    };

    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 0;
    };

    screencapture = {
      location = "~/Desktop";
      type = "png";
    };

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
