{ pkgs }:

{
  quickshell-lumine = pkgs.callPackage ./quickshell { };
  delhommais-com = pkgs.callPackage ./delhommais-com { };
}
