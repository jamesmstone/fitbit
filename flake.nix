{
  description = "James's Fitbit takeout export as a Datasette-ready SQLite database";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      packages = eachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          fitbit-to-sqlite = pkgs.callPackage ./fitbit-to-sqlite.nix { };
        in
        {
          inherit fitbit-to-sqlite;
          default = pkgs.callPackage ./db.nix { inherit fitbit-to-sqlite; };
        }
      );

      checks = eachSystem (system: {
        build = self.packages.${system}.default;
      });

      devShells = eachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              self.packages.${system}.fitbit-to-sqlite
              pkgs.sqlite-utils
            ];
          };
        }
      );
    };
}
