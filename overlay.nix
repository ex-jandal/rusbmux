final: prev: {
  rusbmux = import ./default.nix {
    inherit (prev) stdenv lib rustPlatform;
  };
}