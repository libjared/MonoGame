# vim: set et sw=2 ts=2 number:
{
  description = "Monogame";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
    baseName = "monogamedesktopgl";

    nixlessSource = pkgs.lib.sources.cleanSourceWith {
      src = self;
      name = baseName;
      filter = name: type: let baseFileName = baseNameOf (toString name); in ! (
        pkgs.lib.hasSuffix ".nix" baseFileName ||
        baseFileName == "flake.lock"
      );
    };

    monogamedesktopgl = pkgs.stdenvNoCC.mkDerivation {
      inherit baseName;
      src = nixlessSource;
      version = "3.8.0.1642";

      buildPhase = ''
        dotnet pack
      '';
    };

  in {
    packages.x86_64-linux = {
      inherit monogamedesktopgl;
    };
    defaultPackage.x86_64-linux = monogamedesktopgl;
  };
}
