{
  python3Packages,
  fetchPypi,
}:
python3Packages.buildPythonApplication rec {
  pname = "fitbit-to-sqlite";
  version = "0.6";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-DaAq30TU4hl1ViK3o+cIeGcANdHEDn69Fm5rLcVnX6c=";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    click
    sqlite-utils
  ];

  pythonImportsCheck = [ "fitbit_to_sqlite" ];

  meta = {
    description = "Save data from a Fitbit takeout export to an SQLite database";
    homepage = "https://github.com/mrphil007/fitbit-to-sqlite";
    mainProgram = "fitbit-to-sqlite";
  };
}
