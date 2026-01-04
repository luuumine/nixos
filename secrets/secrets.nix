let
  lumine = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOSF50b9uHqWXQgWC7T5dg2VMBYqI4T4I6VnEkm2R5aX lumine@luminix";
  luminix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9lU2TMuT7YUamnb9dNQsA00tVSd6gOAu721USnRBeP root@luminix";
in
{
  "wg-home.age".publicKeys = [ lumine luminix ];
}

