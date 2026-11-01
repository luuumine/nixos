{ stdenvNoCC }:

let
  pkg = stdenvNoCC.mkDerivation {
    pname = "wallpapers";
    version = "1.0.0";

    src = ./.;

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r * $out/

      runHook postInstall
    '';

    passthru = {
      isla = {
        main = "${pkg}/isla/main.png";
        main-logoless = "${pkg}/isla/main-logoless.png";
        secondary = "${pkg}/isla/secondary.png";
      };
    };
  };
in
pkg
