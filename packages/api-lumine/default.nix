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
  version = "1.3.0";

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

  cargoHash = "sha256-CR29icVz9wp7boPswWbKkifAelnaphpX2Se6uEAE9UY=";

  nativeBuildInputs = [
    cargo
    rustc
    rust-analyzer
    rustfmt
    cacert
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
