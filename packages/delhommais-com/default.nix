{
  stdenv,
  vscode-langservers-extracted,
  prettier,
  ...
}:
let
  pname = "delhommais-com";
  version = "4.1.0";
  src = ./src;
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    vscode-langservers-extracted
    prettier
  ];

  dontBuild = true;
  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';
}
