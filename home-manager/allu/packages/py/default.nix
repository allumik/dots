
{ pkgs, lib, replaceVars }:

self: super: {
  "gamma-launcher" = super.buildPythonPackage rec {
    pname = "gamma-launcher";
    version = "v2.5";
    format = "pyproject";
    src = pkgs.fetchFromGitHub {
      owner = "Mord3rca";
      repo = pname;
      rev = version; # "v${version}"
      sha256 = "qzjfgDFimEL6vtsJBubY6fHsokilDB248WwHJt3F7fI="; # "WRuqmoR2LM8niuLzCTXSS6DEGANBje/yVuEKMLYcwDc=";
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
      self."py7zr"
      self.requests
      self.tenacity
      self.tqdm
      self."unrar"
      self.gitpython
      self.platformdirs
    ];
  };

  "py7zr" = super.buildPythonPackage rec {
    pname = "py7zr";
    version = "0.22.0";
    format = "pyproject";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "c6c7aea5913535184003b73938490f9a4d8418598e533f9ca991d3b8e45a139e";
    };
    doCheck = false;
    nativeBuildInputs = [
      self.setuptools
      self.setuptools-scm
    ];
    propagatedBuildInputs = [
      self.texttable
      self.pycryptodomex
      # here we goooooo...
    	self."pyzstd"
    	self."pyppmd"
    	self."pybcj"
    	self."multivolumefile"
    	self."inflate64"
    	self.brotli
    	self.psutil
    ];
  };

  "unrar" = super.buildPythonPackage rec {
    pname = "unrar";
    version = "0.4";
    format = "pyproject";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "b24447a5b93024be600ef8255668ba23a30f451176577b691559ea1359f7d164";
    };
    doCheck = false;
    # buildInputs = [ pkgs.unrar ];
    nativeBuildInputs = [ self.setuptools ];
    env = { UNRAR_LIB_PATH = "${pkgs.unrar}/lib/libunrar.so"; };
    # patch the library for the correct nix/store unrar lib

    patches = [
      # Generate the substituted patch file in the Nix store
      (pkgs.writeText "unrar_lib_substituted.patch" (
        # Read the original patch file content
        let patchContent = builtins.readFile ./unrar_lib.patch;
        in
        # Replace the placeholder within the content
        builtins.replaceStrings 
          ["@unrar_lib@"]  # Placeholder(s) to find in the patch file
          ["${pkgs.unrar}/lib/libunrar.so"] # Value(s) to substitute
          patchContent 
      ))
    ];
  };

  "pyzstd" = super.buildPythonPackage rec {
    pname = "pyzstd";
    version = "0.16.2";
    format = "pyproject";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "179c1a2ea1565abf09c5f2fd72f9ce7c54b2764cf7369e05c0bfd8f1f67f63d2";
    };
    preBuild = ''sed -i "s/,<74//g" pyproject.toml''; # remove the upper limit for setuptools
    doCheck = false;
    nativeBuildInputs = [ self.setuptools ];
  };

  "pyppmd" = super.buildPythonPackage rec {
    pname = "pyppmd";
    version = "1.1.0";
    format = "pyproject";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "1d38ce2e4b7eb84b53bc8a52380b94f66ba6c39328b8800b30c2b5bf31693973";
    };
    doCheck = false;
    nativeBuildInputs = [
      self.setuptools
      self.setuptools-scm
    ];
  };

  "pybcj" = super.buildPythonPackage rec {
    pname = "pybcj";
    version = "1.0.2";
    format = "pyproject";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "c7f5bef7f47723c53420e377bc64d2553843bee8bcac5f0ad076ab1524780018";
    };
    doCheck = false;
    nativeBuildInputs = [
      self.setuptools
      self.setuptools-scm
    ];
  };

  "multivolumefile" = super.buildPythonPackage rec {
    pname = "multivolumefile";
    version = "0.2.3";
    format = "pyproject";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "a0648d0aafbc96e59198d5c17e9acad7eb531abea51035d08ce8060dcad709d6";
    };
    doCheck = false;
    nativeBuildInputs = [
      self.setuptools
      self.setuptools-scm
    ];
  };

  "inflate64" = super.buildPythonPackage rec {
    pname = "inflate64";
    version = "1.0.0";
    format = "pyproject";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "3278827b803cf006a1df251f3e13374c7d26db779e5a33329cc11789b804bc2d";
    };
    doCheck = false;
    nativeBuildInputs = [
      self.setuptools
      self.setuptools-scm
    ];
  };


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
