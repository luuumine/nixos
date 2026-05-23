{ pkgs }:

{
  quickshell-lumine = pkgs.callPackage ./quickshell-lumine { };
  delhommais-com = pkgs.callPackage ./delhommais-com { };
  wealthfolio-server = pkgs.callPackage ./wealthfolio { };

  luuumine-com-frontend = pkgs.callPackage ./luuumine-com/frontend.nix { };
  luuumine-com-backend = pkgs.callPackage ./luuumine-com/backend.nix { };
}
