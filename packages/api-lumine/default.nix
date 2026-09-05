{
  lib,
  rustPlatform,
  cargo,
  rustc,
  rust-analyzer,
  rustfmt,
  cacert,
}:
let
  pname = "api-lumine";
  version = "1.1.3";

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

  cargoHash = "sha256-qJKP9qg7VE6nd5DPiSQrb0q5Zf0ThzB5MzvmkQxDizI=";

  nativeBuildInputs = [
    cargo
    rustc
    rust-analyzer
    rustfmt
    cacert
  ];

  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  meta = {
    mainProgram = pname;
  };
}
