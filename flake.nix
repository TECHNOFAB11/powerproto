{
  description = "Powerproto";
  inputs.nixpkgs.url = "nixpkgs/nixos-23.05";

  outputs = { self, nixpkgs, systems }:
  let
    version = "0.4.2";
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
    nixpkgsFor = forEachSystem (system: import nixpkgs { inherit system; });
  in {
    # Provide some binary packages for selected system types.
    packages = forEachSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        powerproto = pkgs.buildGoModule {
          pname = "powerproto";
          inherit version;

          src = ./.;
          CGO_ENABLED = 0;

          ldflags = [ "-s" "-w" "-X main.Version=${version}" ];

          vendorSha256 = "sha256-MwL6eA5u7dusWDIgbfyyvNqoP4ZhpSWaQuLsUI+YU9k=";

          doCheck = false;
        };
      }
    );

    defaultPackage = forEachSystem (system: self.packages.${system}.powerproto);
  };
}
