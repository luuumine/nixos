{ pkgs }:

{
  api-lumine = pkgs.callPackage ./api-lumine { };
  photon = pkgs.callPackage ./photon { };
  delhommais-com = pkgs.callPackage ./delhommais-com { };
  killer-game = pkgs.callPackage ./killer-game { };
  luuumine-com = pkgs.callPackage ./luuumine-com { };
  quickshell-lumine = pkgs.callPackage ./quickshell-lumine { };

  # https://github.com/NixOS/nixpkgs/pull/566279
  opengym = pkgs.callPackage ./opengym { };
}
