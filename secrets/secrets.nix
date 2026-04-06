let
  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJKqykgN7RuOz+6YCDWYTeXfGKRHT5VXG/LJWGN1zFro";
  user2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFrzih+mw6XjYG4w2gD21UbQ4X4pP8cq4gIAgeqJZefb";
  users = [ user1 user2 ];

  system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ/3uYYV2AkjhSWQJoD6FJRjCPsUDXG/SblJsrpn4BAL";
  systems = [ system1 ];
in
{
  "wifi.age".publicKeys = users ++ systems;
}
