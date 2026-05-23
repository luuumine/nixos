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
  pname = "luuumine-frontend";
  version = "3.6.3";
  src = ./frontend;
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
    hash = "sha256-I+KJgI5ab+iitxP418+HV0Ki07AeE+TBNzpf/szJ/N8=";
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
