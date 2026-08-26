{
  preservation'.user.directories = [
    {
      directory = "nix-config";
      mode = "0700";
    }

    {
      directory = ".ssh";
      mode = "0700";
    }
  ];
}
