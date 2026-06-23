
{ pkgs, lib, replaceVars }:

self: super: {
  "gamma-launcher" = super.buildPythonPackage rec {
    pname = "gamma-launcher";
    version = "fa324861357c7db1bd3c31a380d7c5b8218b5d95";
    format = "pyproject";
    src = pkgs.fetchFromGitHub {
      owner = "Mord3rca";
      repo = pname;
      rev = version;
      sha256 = "sha256-LD7VuX/aoyoRvQwLkW9JQDlaWFgOOUS6oCUuEXX0Ee4=";
    };
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [
      self.setuptools
    ];
    propagatedBuildInputs = [
      self.beautifulsoup4
      self.cloudscraper
      self.py7zr
      self.requests
      self.tenacity
      self.tqdm
      self.python-unrar
      self.gitpython
      self.platformdirs
    ];
  };
}
