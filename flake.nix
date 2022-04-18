# vim: set et sw=2 ts=2 number:
{
  description = "Monogame";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
    name = "monogamedesktopgl";

    nixlessSource = pkgs.lib.sources.cleanSourceWith {
      inherit name;
      src = self;
      filter = name: type: let baseFileName = baseNameOf (toString name); in ! (
        pkgs.lib.hasSuffix ".nix" baseFileName ||
        baseFileName == "flake.lock"
      );
    };

    monogamedesktopgl = pkgs.stdenvNoCC.mkDerivation {
      inherit name;
      src = nixlessSource;
      version = "3.8.0.1642";
      nativeBuildInputs = [
        pkgs.dotnet-sdk
      ];
      projectFile = "MonoGame.Framework.DesktopGL.csproj";

      # nugetDeps = linkFarmFromDrvs "${name}-nuget-deps" (import ./nuget-deps.nix {
      #   fetchNuGet = { name, version, sha256 }: (let
      #     lowerName = lib.toLower name;
      #     in (fetchurl {
      #       name = "${lowerName}.${version}.nupkg";
      #       url = "https://www.nuget.org/api/v2/package/${name}/${version}";
      #       inherit sha256;
      #     })
      #   );
      # });

      configurePhase = ''
        cd "MonoGame.Framework"
        #dotnet restore --source "$nugetDeps" "$projectFile"
        dotnet restore "$projectFile"
      '';

      buildPhase = ''
        cd "MonoGame.Framework"
        dotnet pack --no-restore "$projectFile"
      '';
    };
  in {
    packages.x86_64-linux = {
      inherit monogamedesktopgl;
    };
    defaultPackage.x86_64-linux = monogamedesktopgl;
  };
}
