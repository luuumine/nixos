{
  perSystem =
    { pkgs, ... }:
    {
      packages.quickshell-lumine = pkgs.stdenv.mkDerivation {
        pname = "quickshell-lumine";
        version = "1.2.0";

        src = ./src;

        buildInputs = [
          pkgs.quickshell
          pkgs.kdePackages.qtdeclarative
        ];

        dontWrapQtApps = true;

        installPhase = ''
          mkdir -p $out
          cp -r . $out/
        '';

        shellHook = ''
          echo "quickshell dev environment active"
          export QML2_IMPORT_PATH="${pkgs.quickshell}/lib/qt-6/qml:${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml:$QML2_IMPORT_PATH"
          export QML_IMPORT_PATH="$QML2_IMPORT_PATH"
        '';

        meta.description = "lumine's quickshell config";
      };
    };
}
