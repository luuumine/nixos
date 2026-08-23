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
  ...
}:

let
  pnpm = pnpm_10;
  pname = "delhommais-com";
  version = "4.0.1";
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
    hash = "sha256-hUw5Emvimzhs1Wz1ZvPLw85aowAKCKKZx50PKsFUMIg=";
  };

  buildPhase = "pnpm build";
  installPhase = "cp -r dist $out";

  shellHook = ''
    export PATH="$PWD/node_modules/.bin:$PATH"
    export NODE_PATH="${typescript}/lib/node_modules:$NODE_PATH"
    echo "astro development environment active"
  '';
}
