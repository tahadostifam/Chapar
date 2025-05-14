{
  description = "Chapar flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, rust-overlay }:
    let
      system = "x86_64-linux";
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs {
        inherit system overlays;
      };
      rustToolchain = pkgs.rust-bin.nightly.latest.default.override {
        extensions = [ "rust-src" "rust-analyzer" "cargo" "clippy" ];
      };
    in
    {
      packages.${system}.default = pkgs.rustPlatform.buildRustPackage {
        pname = "chapar";
        version = "latest";
        src = ./.;
        cargoLock = {
          lockFile = ./Cargo.lock;
        };

        nativeBuildInputs = with pkgs; [
          rustToolchain
          gio-sharp
        ];

        buildPhase = ''
          export LIBRARY_PATH="${pkgs.gio-sharp}/lib:$LIBRARY_PATH"
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp target/release/chapar $out/bin/
        '';

        meta = {
          license = pkgs.lib.licenses.mit;
          description = "Chapar";
          homepage = "https://github.com/tahadostifam/Chapar";
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        name = "chapar-dev-shell";

        buildInputs = with pkgs; [
          rustToolchain
          gio-sharp
        ];

        shellHook = ''
          export LIBRARY_PATH="${pkgs.gio-sharp}/lib:$LIBRARY_PATH"
          alias chapar="cargo run --"
        '';
      };
    };
}
