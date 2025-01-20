{
  # Dependencies:
  lib,
  umu-launcher-unwrapped,
  python3Packages,
  rustPlatform,
  cargo,
  zstd,
  # Public API:
  version,
  withTruststore ? true,
  withDeltaUpdates ? true,
}:
umu-launcher-unwrapped.overridePythonAttrs (prev: {
  src = ../../.;
  inherit version;

  # We can drop old.patches and replace it with the patches we actually need
  patches = [
    ./0-Makefile-no-vendor.patch
  ];

  nativeBuildInputs =
    (prev.nativeBuildInputs or [])
    ++ [
      rustPlatform.cargoSetupHook
      cargo
    ];

  propagatedBuildInputs =
    (prev.propagatedBuildInputs or [])
    ++ lib.optionals withTruststore [
      python3Packages.truststore
    ]
    ++ lib.optionals withDeltaUpdates [
      python3Packages.cbor2
      python3Packages.xxhash
      zstd
    ];

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ../../Cargo.lock;
  };
})
