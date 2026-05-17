{
  stdenv,
  fetchPnpmDeps,
  nodejs_22,
  pnpmConfigHook,
  pnpm,
  astro-language-server,
  typescript,
  typescript-language-server,
  vscode-langservers-extracted,
  ...
}:

let
  pname = "delhommais-com";
  version = "4.0.0";
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
    fetcherVersion = 3;
    hash = "sha256-MnY5rWUVXAfVZvzGQcX8ggIytFmvfqddOzScoJcSz6s=";
  };

  buildPhase = "pnpm build";
  installPhase = "cp -r dist $out";

  shellHook = ''
    export PATH="$PWD/node_modules/.bin:$PATH"
    echo "astro development environment active"
  '';
}
