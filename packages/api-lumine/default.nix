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
  version = "1.1.0";
  src = ./.;
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = "sha256-j9+RfGossJMzxtF5ZbEXD/j1ZJO+1Omb+SzTxMke0XY=";

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
