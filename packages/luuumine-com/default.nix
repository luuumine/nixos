{ pkgs }:

{
  luuumine-com-frontend = pkgs.callPackage ./frontend.nix { };
  luuumine-com-backend = pkgs.callPackage ./backend.nix { };
}
