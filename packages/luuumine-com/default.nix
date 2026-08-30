{
  perSystem = { pkgs, ... }: {
    packages.luuumine-com =
      let
        pnpm = pkgs.pnpm_10;
        pname = "luuumine-com";
        version = "3.9.1";
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
          hash = "sha256-IJOH14ikEQkIxnqmhlV8YfcrAgbWk7OHCRyaMyXv/9w=";
        };

        buildPhase = ''
          export PUBLIC_SITE_VERSION="${version}"
          pnpm build
        '';
        installPhase = "cp -r dist $out";

        shellHook = ''
          export PATH="$PWD/node_modules/.bin:$PATH"
          export NODE_PATH="${pkgs.typescript}/lib/node_modules:$NODE_PATH"
          echo "astro development environment active"
        '';
      };
  };
}
