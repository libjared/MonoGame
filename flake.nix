# vim: set et sw=2 ts=2 number:
{
  description = "One framework for creating powerful cross-platform games.";

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

    monogamedesktopgl = pkgs.buildDotnetModule {
      pname = name;
      src = nixlessSource;
      dotnet-sdk = pkgs.dotnetCorePackages.sdk_6_0;
      dotnet-runtime = pkgs.dotnetCorePackages.runtime_6_0;
      projectFile = "MonoGame.Framework/MonoGame.Framework.DesktopGL.csproj";
      nugetDeps = ./monogamedesktopgl-deps.nix;
      version = "3.8.0.6000";
      packNupkg = true;
      executables = [];
    };

  in {
    packages.x86_64-linux = {
      inherit monogamedesktopgl;
    };
    defaultPackage.x86_64-linux = monogamedesktopgl;
  };
}
