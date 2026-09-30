{ ... }:
{
  preservation'.user.directories = [
    {
      directory = ".config/gh";
      mode = "0700";
    }
    ".local/state/lazygit"
  ];
}
