{
  stdenvNoCC,
  fitbit-to-sqlite,
}:
stdenvNoCC.mkDerivation {
  pname = "fitbit-db";
  version = "2023-04-14";

  src = ./MyFitbitData.zip;
  dontUnpack = true;

  nativeBuildInputs = [ fitbit-to-sqlite ];

  buildPhase = ''
    runHook preBuild
    for subset in resting-heart-rate distance minutes-active exercise heart-rate-zones; do
      fitbit-to-sqlite "$subset" fitbit.db "$src"
    done
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm444 fitbit.db "$out/fitbit.db"
    runHook postInstall
  '';
}
