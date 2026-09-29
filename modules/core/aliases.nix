# Option aliases for the primary user.
{ lib, myvars, ... }:
{
  imports = [
    (lib.mkAliasOptionModule [ "user'" ] [ "users" "users" myvars.username ])
    (lib.mkAliasOptionModule [ "hm'" ] [ "home-manager" "users" myvars.username ])
  ];
}
