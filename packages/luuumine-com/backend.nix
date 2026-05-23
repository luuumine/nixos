{
  stdenv,
  fetchPnpmDeps,
  nodejs_22,
  pnpmConfigHook,
  pnpm,
  tsx,
  typescript,
  typescript-language-server,
  vscode-langservers-extracted,
}:
let
  pname = "luuumine-backend";
  version = "0.1";
  src = ./backend;
in

stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    nodejs_22
    pnpmConfigHook
    pnpm
    typescript
    typescript-language-server
    vscode-langservers-extracted
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit pname version src;
    fetcherVersion = 3;
    hash = "sha256-dMzr5LUT8c85kgncKSTmNU9ZHt3CG0ngEZtYIjv9AHI=";
  };

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
    mkdir -p $out/bin

    cat <<EOF > $out/bin/luuumine-api
    #!/bin/sh
    cd $out
    exec ${tsx}/bin/tsx src/index.ts "\$@"
    EOF

    chmod +x $out/bin/luuumine-api
  '';

  meta = {
    mainProgram = "luuumine-api";
  };
}
