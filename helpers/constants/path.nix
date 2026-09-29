# Paths derived from the primary user.
{ user }:
rec {
  homeDirectory = "/home/${user.username}";

  # Directory name of the repository checkout inside the home directory.
  nixConfigDir = "nix-config";

  # Absolute path of the checkout, read by nh and the user.
  nixConfig = "${homeDirectory}/${nixConfigDir}";
}
