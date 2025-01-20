{
  description = "umu universal game launcher";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    inherit (nixpkgs) lib;

    # Utility function for producing consistent rename warning messages
    rename = old: new: lib.warn "`${old}` has been renamed to `${new}`";

    # Package sets supported by umu-launcher-unwrapped
    # { system = pkgs; }
    supportedPkgs =
      lib.filterAttrs
      (system: pkgs: builtins.elem system pkgs.umu-launcher-unwrapped.meta.platforms)
      nixpkgs.legacyPackages;

    # Use the current revision for the default version
    version = self.dirtyShortRev or self.shortRev or self.lastModifiedDate;
  in {
    overlays.default = final: prev: {
      umu-launcher = final.callPackage ./package.nix {};
      umu-launcher-unwrapped = final.callPackage ./unwrapped.nix {
        inherit version;
        inherit (prev) umu-launcher-unwrapped;
      };
      # Deprecated in https://github.com/Open-Wine-Components/umu-launcher/pull/345 (2025-01-24)
      umu = rename "umu" "umu-launcher" final.umu-launcher;
      umu-run = rename "umu-run" "umu-launcher" final.umu-launcher;
    };

    formatter = builtins.mapAttrs (system: pkgs: pkgs.alejandra) nixpkgs.legacyPackages;

    packages =
      builtins.mapAttrs (system: pkgs: rec {
        default = umu-launcher;
        umu-launcher = pkgs.callPackage ./package.nix {
          inherit umu-launcher-unwrapped;
        };
        umu-launcher-unwrapped = pkgs.callPackage ./unwrapped.nix {
          inherit version;
          inherit (pkgs) umu-launcher-unwrapped;
        };
        # Deprecated in https://github.com/Open-Wine-Components/umu-launcher/pull/345 (2025-01-24)
        umu = rename "packages.${system}.umu" "packages.${system}.umu-launcher" umu-launcher;
      })
      supportedPkgs;
  };
}
