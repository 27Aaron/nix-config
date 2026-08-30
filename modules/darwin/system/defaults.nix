###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
#  Incomplete list of macOS `defaults` commands :
#    https://github.com/yannbertrand/macos-defaults
#
###################################################################################
{
  config,
  lib,
  ...
}: let
  cfg = config.system'.defaults;
in {
  options.system'.defaults = {
    enable = lib.mkEnableOption "macOS system defaults";
  };

  config = lib.mkIf cfg.enable {
    system.defaults = {
      menuExtraClock.Show24Hour = true; # show 24 hour clock
      menuExtraClock.ShowSeconds = true;

      # customize dock
      dock = {
        autohide = true; # 自动隐藏 Dock
        show-recents = false; # 禁用最近应用

        # 触发角
        wvous-tl-corner = 2; # Mission Control
        wvous-tr-corner = 4; # Desktop
        wvous-bl-corner = 3; # Application Windows
        wvous-br-corner = 13; # Lock Screen
      };

      finder = {
        _FXShowPosixPathInTitle = true; # 显示Finder标题中的完整路径
        _FXSortFoldersFirst = true; # 文件夹排序在文件之前
        AppleShowAllExtensions = true; # 显示所有文件扩展名
        FXDefaultSearchScope = "SCcf"; # 搜索时默认仅搜索当前文件夹
        FXEnableExtensionChangeWarning = false; # 更改文件扩展名时禁用警告
        NewWindowTarget = "Home"; # 新 Finder 窗口默认显示用户主目录
        QuitMenuItem = true; # 启用退出菜单项
        ShowPathbar = true; # 显示路径栏
        ShowStatusBar = true; # 显示状态栏
        ShowExternalHardDrivesOnDesktop = true; # 桌面显示外接硬盘
        ShowHardDrivesOnDesktop = false; # 桌面不显示内置硬盘
        ShowMountedServersOnDesktop = true; # 桌面显示已挂载的服务器
        ShowRemovableMediaOnDesktop = true; # 桌面显示可移动介质
      };

      spaces.spans-displays = false; # 显示器各自拥有独立空间

      WindowManager = {
        EnableStandardClickToShowDesktop = false; # 点击壁纸不进入桌面
        StandardHideDesktopIcons = false; # 桌面显示图标
        HideDesktop = false; # 不隐藏桌面与台前调度中的项目
        StageManagerHideWidgets = false; # 台前调度不隐藏小组件
        StandardHideWidgets = false; # 点击壁纸显示桌面时不隐藏小组件
      };

      screensaver = {
        askForPassword = true; # 屏保或睡眠后立即要求密码
        askForPasswordDelay = 0;
      };

      screencapture = {
        location = "~/Desktop"; # 截图保存位置
        type = "png"; # 截图格式
      };

      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = true; # 启用自然滚动（默认为true）
        "com.apple.sound.beep.feedback" = 0; # 关闭系统音量变化时的提示音

        # Appearance
        AppleInterfaceStyle = "Dark"; # 深色模式

        AppleKeyboardUIMode = 2; # 配置键盘控制行为

        InitialKeyRepeat = 15; # 正常最小值为15（225毫秒），最大值为120（1800毫秒）
        KeyRepeat = 3; # 正常最小值为2（30毫秒），最大值为120（1800毫秒）

        NSAutomaticCapitalizationEnabled = false; # 是否启用自动大写
        NSAutomaticDashSubstitutionEnabled = false; # 是否启用智能减号替换
        NSAutomaticPeriodSubstitutionEnabled = false; # 是否启用智能句号替换
        NSAutomaticQuoteSubstitutionEnabled = false; # 是否启用智能引号替换
        NSAutomaticSpellingCorrectionEnabled = false; # 是否启用自动拼写检查
        NSNavPanelExpandedStateForSaveMode = true; # 保存文件时的路径选择/文件名输入页
        NSNavPanelExpandedStateForSaveMode2 = true; # 保存文件时的路径选择/文件名输入页
      };

      # Customize settings that not supported by nix-darwin directly
      # see the source code of this project to get more undocumented options:
      #    https://github.com/rgcr/m-cli
      #
      # All custom entries can be found by running `defaults read` command.
      # or `defaults read xxx` to read a specific domain.
      CustomUserPreferences = {
        ".GlobalPreferences" = {
          # automatically switch to a new space when switching to the application
          AppleSpacesSwitchOnActivate = true;
        };
        NSGlobalDomain = {
          # Add a context menu item for showing the Web Inspector in web views
          WebKitDeveloperExtras = true;
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;
      };
    };
  };
}
