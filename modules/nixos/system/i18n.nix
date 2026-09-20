{
  i18n = {
    defaultLocale = "en_US.UTF-8";

    # English is the default. Chinese overrides only the categories where the
    # en_US default is factually wrong for China (metric, A4, CNY); everything
    # else, including date/time names, stays English.
    extraLocaleSettings = {
      LC_MEASUREMENT = "zh_CN.UTF-8";
      LC_MONETARY = "zh_CN.UTF-8";
      LC_PAPER = "zh_CN.UTF-8";
    };
  };
}
