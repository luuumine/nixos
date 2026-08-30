{
  perSystem =
    { pkgs, ... }:
    {
      packages.delhommais-com =
        let
          pnpm = pkgs.pnpm_10;
          pname = "delhommais-com";
          version = "4.0.1";
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
            hash = "sha256-hUw5Emvimzhs1Wz1ZvPLw85aowAKCKKZx50PKsFUMIg=";
          };

          buildPhase = "pnpm build";
          installPhase = "cp -r dist $out";

          shellHook = ''
            export PATH="$PWD/node_modules/.bin:$PATH"
            export NODE_PATH="${pkgs.typescript}/lib/node_modules:$NODE_PATH"
            echo "astro development environment active"
          '';
        };
    };
}
