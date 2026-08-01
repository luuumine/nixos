{
  stdenv,
  fetchPnpmDeps,
  nodejs_22,
  pnpmConfigHook,
  pnpm_10,
  astro-language-server,
  typescript,
  typescript-language-server,
  vscode-langservers-extracted,
}:
let
  pnpm = pnpm_10.override { nodejs-slim = nodejs_22; };
  pname = "killer-game";
  version = "1.0.0";
  src = ./.;
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    nodejs_22
    pnpmConfigHook
    pnpm
    astro-language-server
    typescript
    typescript-language-server
    vscode-langservers-extracted
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-To+eQC0068jFx68anCeH//HGWmlQfGT85ohwUmjyLiI=";
  };

  buildPhase = ''
    pnpm build
  '';
  installPhase = ''
    mkdir -p $out
    cp -r dist $out/
    cp -r node_modules $out/
    cp package.json $out/
  '';

  shellHook = ''
    export PATH="$PWD/node_modules/.bin:$PATH"
    export NODE_PATH="${typescript}/lib/node_modules:$NODE_PATH"
    echo "killer development environment active"
  '';
}
