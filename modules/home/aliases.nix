{ lib, username, ... }:
{
  # Short alias for the primary user's Home Manager module.
  imports = [
    (lib.mkAliasOptionModule [ "hm'" ] [ "home-manager" "users" username ])
  ];
}
