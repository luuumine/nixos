{ pkgs }:

{
  api-lumine = pkgs.callPackage ./api-lumine { };
  delhommais-com = pkgs.callPackage ./delhommais-com { };
  luuumine-com = pkgs.callPackage ./luuumine-com { };
  quickshell-lumine = pkgs.callPackage ./quickshell-lumine { };
  wealthfolio-server = pkgs.callPackage ./wealthfolio { };
}
