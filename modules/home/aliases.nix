{ lib, username, ... }:
{
  # Short aliases for the primary user's system and Home Manager modules.
  imports = [
    (lib.mkAliasOptionModule [ "user'" ] [ "users" "users" username ])
    (lib.mkAliasOptionModule [ "hm'" ] [ "home-manager" "users" username ])
  ];
}
