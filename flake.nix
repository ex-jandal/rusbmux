{
  description = "rusbmux — a usbmuxd replacement in pure Rust";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    crane.url = "github:ipetkov/crane";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , crane
    }:
    flake-utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ] (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      craneLib = crane.mkLib pkgs;

      commonArgs = {
        pname = "rusbmux";
        version = "0.2.1";
        src = craneLib.cleanCargoSource (craneLib.path ./.);
        strictDeps = true;
        meta = with pkgs.lib; {
          description = "A usbmuxd replacement in pure Rust";
          homepage = "https://github.com/abdullah-albanna/rusbmux";
          license = with licenses; [ mit asl20 ];
          platforms = platforms.linux ++ platforms.darwin;
          mainProgram = "rusbmux";
        };
      };

      cargoArtifacts = craneLib.buildDepsOnly commonArgs;

      rusbmux = craneLib.buildPackage (commonArgs // {
        inherit cargoArtifacts;
      });

      rusbmux-tests = craneLib.cargoTest (commonArgs // {
        inherit cargoArtifacts;
      });
    in
    {
      packages = {
        rusbmux = rusbmux;
        default = rusbmux;
      };

      checks = {
        rusbmux = rusbmux-tests;
        default = rusbmux-tests;
      };

      devShells.default = craneLib.devShell {
        checks = self.checks.${system};
        packages = with pkgs; [
          rust-analyzer
          nixpkgs-fmt
        ];
      };
    }) // {
    overlays.default = final: prev: {
      rusbmux = self.packages.${final.system}.default;
    };

    nixosModules.default = {
      _file = ./nixos-module.nix;
      imports = [ ./nixos-module.nix ];

      # Make pkgs.rusbmux available so the module's default package
      # (services.rusbmux.package = pkgs.rusbmux) resolves on its own.
      nixpkgs.overlays = [ self.overlays.default ];
    };
  };
}