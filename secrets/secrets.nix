let
  # users
  lumine = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOSF50b9uHqWXQgWC7T5dg2VMBYqI4T4I6VnEkm2R5aX lumine";

  # systems
  luminadel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgexWnRfrJ3PywZlt+h9ly0jclK+s6MThdKGt0g2JFY root@luminadel";
  luminix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9lU2TMuT7YUamnb9dNQsA00tVSd6gOAu721USnRBeP root@luminix";

  # groups
  users = [ lumine ];
  systems = [
    luminadel
    luminix
  ];
  allKeys = users ++ systems;
in
{
  "luminadel/caddy.age".publicKeys = users ++ [ luminadel ];
  "luminadel/mullvad.age".publicKeys = users ++ [ luminadel ];
}
