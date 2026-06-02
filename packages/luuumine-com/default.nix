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
}:
let
  pname = "luuumine-com";
  version = "3.6.3";
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
    hash = "sha256-+zRbvmbgg13HF+Gch9edpggp4DSn3BfYKeK7k9i1Wkk=";
  };

  buildPhase = ''
    export PUBLIC_SITE_VERSION="${version}"
    pnpm build
  '';
  installPhase = "cp -r dist $out";

  shellHook = ''
    export PATH="$PWD/node_modules/.bin:$PATH"
    echo "astro development environment active"
  '';
}
