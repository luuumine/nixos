{ pkgs }:

{
  quickshell-lumine = pkgs.callPackage ./quickshell { };
  delhommais-com = pkgs.callPackage ./delhommais-com { };
  wealthfolio-server = pkgs.callPackage ./wealthfolio { };
}
