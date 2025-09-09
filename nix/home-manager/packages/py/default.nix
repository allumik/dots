
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
      # here we goooooo
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
}
