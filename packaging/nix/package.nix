{
  # Dependencies:
  lib,
  buildFHSEnv,
  umu-launcher-unwrapped,
  # Public API:
  version ? null,
  withTruststore ? args.truststore or true,
  withDeltaUpdates ? true,
  # Deprecated in https://github.com/Open-Wine-Components/umu-launcher/pull/345 (2025-01-24)
  # NOTE: we rely on pkgs not having `truststore` or `cbor2` at the top-level...
  # We check for these args being supplied by end-users. If they were in pkgs,
  # then `callPackage` would supply them, causing false-positives.
  truststore ? null,
  cbor2 ? null,
} @ args: let
  overridden = umu-launcher-unwrapped.override (
    lib.optionalAttrs (args ? version) {inherit version;}
    // lib.optionalAttrs (args ? withTruststore || args ? truststore) {
      withTruststore =
        lib.warnIf (args ? truststore)
        "umu-launcher: the argument `truststore` has been renamed to `withTruststore`."
        withTruststore;
    }
    // lib.optionalAttrs (args ? withDeltaUpdates) {inherit withDeltaUpdates;}
    // lib.warnIf (args ? cbor2)
    "umu-launcher: the argument `cbor2` has never had any effect. The new argument `withDeltaUpdates` should be used instead." {}
  );
in
  # We cannot override everything we need to, so re-implement the package
  # See https://github.com/NixOS/nixpkgs/pull/375588
  # Tracker https://nixpk.gs/pr-tracker.html?pr=375588
  buildFHSEnv {
    pname = "umu-launcher";
    inherit (overridden) version meta;
    executableName = overridden.meta.mainProgram;

    targetPkgs = pkgs: [overridden];
    runScript = lib.getExe overridden;

    extraInstallCommands = ''
      ln -s ${overridden}/lib $out/lib
      ln -s ${overridden}/share $out/share
    '';
  }
