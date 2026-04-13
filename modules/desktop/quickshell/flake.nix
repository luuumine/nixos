{
  description = "Quickshell Dev Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          quickshell
          kdePackages.qtdeclarative
        ];

        shellHook = ''
          echo "Quickshell Development Environment Active"
          export QML2_IMPORT_PATH="${pkgs.quickshell}/lib/qt-6/qml:${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml:$QML2_IMPORT_PATH"
          export QML_IMPORT_PATH="$QML2_IMPORT_PATH"
        '';
      };
    };
}
