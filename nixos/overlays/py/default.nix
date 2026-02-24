
{ pkgs, lib, replaceVars }:

self: super: {
  "gamma-launcher" = super.buildPythonPackage rec {
    pname = "gamma-launcher";
    version = "v2.6";
    format = "pyproject";
    src = pkgs.fetchFromGitHub {
      owner = "Mord3rca";
      repo = pname;
      rev = version; # "v${version}"
      sha256 = "QegptRWMUKpkzsHBdT6KlyyWpmrIuvcyCRvWT9Te3DQ="; # "WRuqmoR2LM8niuLzCTXSS6DEGANBje/yVuEKMLYcwDc=";
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


  ## TODO: wait until python314 becomes stable
  #### things added in next stable release
  "euporie" = super.buildPythonPackage rec {
    pname = "euporie";
    version = "2.8.13";
    pyproject = true;
  
    src = pkgs.fetchFromGitHub {
      repo = "euporie";
      owner = "joouha";
      tag = "v${version}";
      hash = "sha256-T+Zec5vb+y5qf7Xvv+QtVG+olnv2C0933tCJbEQAJuU=";
    };
  
    build-system = [
      self.setuptools
      self.hatchling
    ];
  
    dependencies = [
      self.aenum
      self.aiohttp
      self.prompt-toolkit
      self.pygments
      self.nbformat
      self.jupyter-client
      self.typing-extensions
      self.fastjsonschema
      self.platformdirs
      self.pyperclip
      self.imagesize
      self.markdown-it-py
      self.linkify-it-py
      self.mdit-py-plugins
      self."flatlatex"
      self."timg"
      self.pillow
      self."sixelcrop"
      self.universal-pathlib
      self.fsspec
      self.jupytext
      self.ipykernel
    ];
  
    pythonRelaxDeps = [
      "aenum"
      "linkify-it-py"
      "markdown-it-py"
      "mdit-py-plugins"
      "platformdirs"
    ];
  
    meta = {
      description = "Jupyter notebooks in the terminal";
      longDescription = ''
        Similar to `jupyter lab` or `jupyter notebook`, This package
        can only be used inside a python environment. To quickly summon
        a python environment with euporie, you can use:
        ```
        nix-shell -p 'python3.withPackages (ps: with ps; [ euporie ])'
        ```
      '';
      homepage = "https://euporie.readthedocs.io/";
      license = lib.licenses.mit;
      mainProgram = "euporie";
    };
  };

  "flatlatex" = super.buildPythonPackage rec {
    pname = "flatlatex";
    version = "0.15";
    pyproject = true;
  
    src = super.fetchPypi {
      inherit pname version;
      hash = "sha256-UXDhvNT8y1K9vf8wCxS2hzBIO8RvaiqJ964rsCTk0Tk=";
    };
  
    build-system = [
      self.setuptools
    ];
  
    dependencies = [
      self.regex
    ];
  
    nativeCheckInputs = [
      self.pytestCheckHook
    ];
  
    pythonImportsCheck = [
      "flatlatex"
    ];
  
    meta = {
      description = "LaTeX math converter to unicode text";
      homepage = "https://github.com/jb-leger/flatlatex";
      license = lib.licenses.bsd2;
    };
  };

  "timg" = super.buildPythonPackage rec {
    pname = "timg";
    version = "1.1.6";
    pyproject = true;
  
    src = super.fetchPypi {
      inherit pname version;
      hash = "sha256-k42TmsNQIwD3ueParfXaD4jFuG/eWILXO0Op0Ci9S/0=";
    };
  
    build-system = [
      super.setuptools
    ];
  
    dependencies = [
      super.pillow
    ];
  
    pythonImportsCheck = [
      "timg"
    ];
  
    meta = {
      description = "Display an image in terminal";
      homepage = "https://github.com/adzierzanowski/timg";
      license = lib.licenses.mit;
    };
  };

  "sixelcrop" = super.buildPythonPackage rec {
    pname = "sixelcrop";
    version = "0.1.9";
    pyproject = true;
  
    src = super.fetchPypi {
      inherit pname version;
      hash = "sha256-1sBaxPvW4gH3lK3tEjAPtCdXMXLAVEof0lpIpmpbyG8=";
    };
  
    build-system = [
      super.hatchling
    ];
  
    pythonImportsCheck = [
      "sixelcrop"
    ];
  
    meta = {
      description = "Crop sixel images in sixel-space!";
      homepage = "https://github.com/joouha/sixelcrop";
      license = lib.licenses.mit;
    };
  };
}
