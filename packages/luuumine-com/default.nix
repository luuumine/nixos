{
  stdenv,
  zola,
  marksman,
  vscode-langservers-extracted,
  prettier,
  typescript-language-server,
}:
let
  pname = "luuumine-com";
  version = "4.0.0";
  src = ./.;
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    zola
    marksman
    vscode-langservers-extracted
    prettier
    typescript-language-server
  ];

  buildPhase = ''
    export PUBLIC_SITE_VERSION="${version}"
    zola build
  '';

  installPhase = ''
    cp -r public $out
  '';

  shellHook = ''
    export PUBLIC_SITE_VERSION="${version}-dev"
  '';
}
