{
  perSystem =
    { pkgs, ... }:
    {
      packages.killer-game =
        let
          pnpm = pkgs.pnpm_10.override { nodejs-slim = pkgs.nodejs_22; };
          pname = "killer-game";
          version = "1.1.1";
          src = ./.;
        in
        pkgs.stdenv.mkDerivation {
          inherit pname version src;

          nativeBuildInputs = [
            pkgs.nodejs_22
            pkgs.pnpmConfigHook
            pnpm
            pkgs.astro-language-server
            pkgs.typescript
            pkgs.typescript-language-server
            pkgs.vscode-langservers-extracted
          ];

          pnpmDeps = pkgs.fetchPnpmDeps {
            inherit pname version src;
            inherit pnpm;
            fetcherVersion = 3;
            hash = "sha256-Ops0pA+yhpY/eTYNZT/JJiEGBCpEQkmWvRzCm+4vuU4=";
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
            export NODE_PATH="${pkgs.typescript}/lib/node_modules:$NODE_PATH"
            echo "killer development environment active"
          '';
        };
    };
}
