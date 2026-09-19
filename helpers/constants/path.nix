# Paths derived from the platform and the primary user.
{ platformName, user }:
rec {
  homeDirectory =
    if platformName == "darwin" then "/Users/${user.username}" else "/home/${user.username}";

  # Directory name of the repository checkout inside the home directory.
  nixConfigDir = "nix-config";

  # Absolute path of the checkout, read by nh and the user.
  nixConfig = "${homeDirectory}/${nixConfigDir}";
}
