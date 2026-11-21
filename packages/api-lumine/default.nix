{
  lib,
  rustPlatform,
  cargo,
  rustc,
  rust-analyzer,
  rustfmt,
  pkg-config,
  aws-lc,
  cacert,
  sqlite,
}:
let
  pname = "api-lumine";
  version = "1.3.1";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./Cargo.toml
      ./Cargo.lock
      ./src
      ./migrations
      ./tests
    ];
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = "sha256-lTpiNA6gOUMLlyIxOuAR0n48zz8K87QZgisnEYCXq+o=";

  nativeBuildInputs = [
    cargo
    rustc
    rust-analyzer
    rustfmt
    pkg-config
    cacert
  ];

  buildInputs = [
    aws-lc
    sqlite
  ];

  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  API_VERSION = version;

  shellHook = ''
    export API_VERSION="${version}-dev"
  '';

  meta = {
    mainProgram = pname;
  };
}
