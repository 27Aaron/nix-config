{ ... }:
{
  preservation'.user.directories = [
    {
      directory = ".atuin";
      mode = "0700";
    }
    ".local/share/atuin"
  ];
}
