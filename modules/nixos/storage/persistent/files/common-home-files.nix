{
  preservation'.user.files = [
    # AI assistants
    {
      file = ".claude.json";
      how = "bindmount";
    }

    # WakaTime
    ".wakatime.cfg"
  ];
}
