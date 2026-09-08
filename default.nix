{ stdenv
, lib
, rustPlatform
}:
rustPlatform.buildRustPackage {
  pname = "rusbmux";
  version = "0.2.1";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    description = "A usbmuxd replacement in pure Rust";
    homepage = "https://github.com/abdullah-albanna/rusbmux";
    license = with lib.licenses; [ mit asl20 ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "rusbmux";
  };
}