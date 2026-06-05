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
  version = "1.0.0";
  src = ./.;
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = "sha256-2jVZGp1WB52u2PRk/3Aie3MQYDO7ceM2zOcsf5NGzWk=";

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
