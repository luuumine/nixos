{ pkgs }:

{
  api-lumine = pkgs.callPackage ./api-lumine { };
  delhommais-com = pkgs.callPackage ./delhommais-com { };
  killer-game = pkgs.callPackage ./killer-game { };
  luuumine-com = pkgs.callPackage ./luuumine-com { };
  quickshell-lumine = pkgs.callPackage ./quickshell-lumine { };
}
