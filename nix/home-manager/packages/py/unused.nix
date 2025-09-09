
{ pkgs, lib }:

self: super: {
  "scanpy" = super.buildPythonPackage rec {
    pname = "scanpy";
    version = "1.9.4";
    format = "pyproject";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "14957604d251c665d42a8fe55b51b6d19867c3e987054b12e65c762d13664463";
    };
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [
      self.flit
      self.setuptools-scm
    ];
    propagatedBuildInputs = [
      self."anndata"
      self.h5py
      self.importlib-metadata
      self.joblib
      self.matplotlib
      self.natsort
      self.networkx
      self.numba
      self.numpy
      self.packaging
      self.pandas
      self.patsy
      self.scikit-learn
      self.scipy
      self.seaborn
      self."session-info" # have to build this one
      self.statsmodels
      self.tqdm
      self.umap-learn
    ];
  };
  "session-info" = super.buildPythonPackage rec {
    # note the underscore "_" here instead of "-"
    pname = "session_info"; 
    version = "1.0.0";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "3cda5e03cca703f32ae2eadbd6bd80b6c21442cfb60e412c21cb8ad6d5cbb6b7";
    };
    format = "setuptools";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [
      self.stdlib-list
    ];
  };


  "anndata" = super.buildPythonPackage rec {
    pname = "anndata";
    version = "0.9.2";
    format = "pyproject";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "e5b8383d09723af674cae7ad0c2ef53eb1f8c73949b7f4c182a6e30f42196327";
    };
    doCheck = false; # skip this for now
    buildInputs = [];
    checkInputs = [
      pkgs.pre-commit
      self.pre-commit-hooks
    ];
    nativeBuildInputs = [
      self.hatchling
      self.hatch-vcs
      self.flit
    ];
    propagatedBuildInputs = [
      self.pandas
      self.numpy
      self.scipy
      self.h5py
      self.exceptiongroup
      self.natsort
      self.packaging
      self."array_api_compat"
    ];
  };
  "array_api_compat" = super.buildPythonPackage rec {
    pname = "array_api_compat";
    version = "1.3";
    format = "pyproject";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "8fc9e6932fa50d7519adf2ec2de6884cf2b1fa509d4a28f482977ac3234e546a";
    };
    doCheck = false;
    buildInputs = [];
    nativeBuildInputs = [
      self.pkgconfig
      self.setuptools
    ];
  };

  # scvi-tools next 
  # NB: DONT
  "scvi-tools" = super.buildPythonPackage rec {
    # again with the underscores
    pname = "scvi_tools";
    version = "1.0.3";
    format = "pyproject";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "2cda6a82c6bf5d01f2913e47b6397491791c23c7f98c25098dd4d291c843e8f0";
    };
    doCheck = false; # skip this for now
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [
      self.hatchling
      self.hatch-vcs
      self."flax"
    ];
    propagatedBuildInputs = [
      self.anndata
      self.chex
      self.typing-extensions
      self.docrep
      self.jax
      self.jaxlib
      self.optax
      self.numpy
      self.pandas
      self.scipy
      self.scikit-learn
      self.rich
      self.h5py
      self.torch
      self.pytorch-lightning
      self.torchmetrics
      self.pyro-ppl
      self.tqdm
      self.numpyro
      self.ml-collections
      self."mudata"
      self.sparse
      self.xarray
    ];
  };
  chex is missing a dep in nixpkgs in 23.05
  "chex" = super.buildPythonPackage rec {
    pname = "chex";
    version = "0.1.6";
    format = "setuptools";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "adb5d2352b5f0d248ccf594be1b1bf9ee7a2bee2a57f0eac78547538d479b0e7";
    };
    propagatedBuildInputs = [
      self.absl-py
      self.cloudpickle
      self.dm-tree
      self.jax
      self.numpy
      self.toolz
      self.typing-extensions
    ];
    pythonImportsCheck = [
      "chex"
    ];
    nativeCheckInputs = [
      self.jaxlib
      self.pytestCheckHook
    ];
    disabledTests = [
      # See https://github.com/deepmind/chex/issues/204.
      "test_uninspected_checks"

      # These tests started failing at some point after upgrading to 0.1.5
      "test_useful_failure"
      "TreeAssertionsTest"
      "PmapFakeTest"
      "WithDeviceTest"
    ];
    meta = with lib; {
      description = "Chex is a library of utilities for helping to write reliable JAX code.";
      homepage = "https://github.com/deepmind/chex";
      license = licenses.asl20;
      maintainers = with maintainers; [ ndl ];
    };
  };
  "mudata" = super.buildPythonPackage rec {
    pname = "mudata";
    version = "0.2.3";
    format = "pyproject";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "45288ac150bfc598d68acb7c2c1c43c38c5c39522107e04f7efbf3360c7f2035";
    };
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [
      self.flit-core
      self."flax"
    ];
    propagatedBuildInputs = [
      self.numpy
      self.pandas
      self.anndata
      self.h5py
    ];
  };
  ## gotta install flax+orbax too, as flax is marked "broken" due to orbax missing...
  "flax" = super.buildPythonPackage rec {
    pname = "flax";
    version = "0.7.2";
    format = "setuptools";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "7f023ece0b8b0d03019d2841dbe780e33b81ec42268bdc3e5d24c8fb0582fd7b";
    };
    doCheck = false;
    buildInputs = [
      self.jaxlib
    ];
    pythonImportsCheck = [
      "flax"
    ];
    nativeCheckInputs = [
      self.keras
      self.pytest-xdist
      self.pytestCheckHook
      self.tensorflow
    ];
    checkInputs = [];
    nativeBuildInputs = [
      self.setuptools-scm
    ];
    propagatedBuildInputs = [
      self.jax
      self.matplotlib
      self.msgpack
      self.numpy
      self.optax
      self.rich
      self."orbax-checkpoint"
      self.tensorstore
      self.typing-extensions
      self.pyyaml
    ];
    pytestFlagsArray = [
      "-W ignore::FutureWarning"
      "-W ignore::DeprecationWarning"
    ];
    disabledTestPaths = [
      # Docs test, needs extra deps + we're not interested in it.
      "docs/_ext/codediff_test.py"

      # The tests in `examples` are not designed to be executed from a single test
      # session and thus either have the modules that conflict with each other or
      # wrong import paths, depending on how they're invoked. Many tests also have
      # dependencies that are not packaged in `nixpkgs` (`clu`, `jgraph`,
      # `tensorflow_datasets`, `vocabulary`) so the benefits of trying to run them
      # would be limited anyway.
      "examples/*"
    ];
    disabledTests = [
      # See https://github.com/google/flax/issues/2554.
      "test_async_save_checkpoints"
      "test_jax_array0"
      "test_jax_array1"
      "test_keep0"
      "test_keep1"
      "test_optimized_lstm_cell_matches_regular"
      "test_overwrite_checkpoints"
      "test_save_restore_checkpoints_target_empty"
      "test_save_restore_checkpoints_target_none"
      "test_save_restore_checkpoints_target_singular"
      "test_save_restore_checkpoints_w_float_steps"
      "test_save_restore_checkpoints"
    ];
    meta = with lib; {
      description = "Flax: A neural network library for JAX designed for flexibility";
      homepage = "https://github.com/google/flax";
      changelog = "https://github.com/google/flax/releases/tag/v${version}";
      license = licenses.asl20;
      maintainers = with maintainers; [ ndl ];
      # Requires orbax which is not available
      # broken = true;
    };
  };
  "orbax-checkpoint" = super.buildPythonPackage rec {
    pname = "orbax_checkpoint";
    version = "0.3.5";
    format = "pyproject";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "fb573e132503c6e9dfa5ff17ff22521f326a6bf929002e3d62d0397c617f9775";
    };
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [
      self.flit-core
    ];
    propagatedBuildInputs = [
      self.absl-py
      self.etils
      self.typing-extensions
      self.msgpack
      self.jax
      self.jaxlib
      self.numpy
      self.pyyaml
      self.tensorstore
      self.nest-asyncio
      self.tensorflow
      self.protobuf
    ];
  };
  "tensorstore" = super.buildPythonPackage rec {
    pname = "tensorstore";
    version = "0.1.41";
    format = "setuptools";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "5168f7f71e51da7d6cc85a11cd5d102d9eae750d5f5a3ee90cc9ebae10226621";
    };
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [
      self.setuptools_scm
      self.wheel
      pkgs.bazel
      pkgs.bazelisk
    ];
    propagatedBuildInputs = [
      self.absl-py
      self.etils
      self.typing-extensions
      self.msgpack
      self.jax
      self.jaxlib
      self.numpy
      self.pyyaml
      self.nest-asyncio
      self.tensorflow
      self.protobuf
    ];
  };
  and also newer jax from "unstable" channel
  "jax" = super.buildPythonPackage rec {
    pname = "jax";
    version = "0.4.14";
    format = "pyproject";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "18fed3881f26e8b13c8cb46eeeea3dba9eb4d48e3714d8e8f2304dd6e237083d";
    };
    nativeBuildInputs = [
      self.setuptools
    ];
    # jaxlib is _not_ included in propagatedBuildInputs because there are
    # different versions of jaxlib depending on the desired target hardware. The
    # JAX project ships separate wheels for CPU, GPU, and TPU.
    propagatedBuildInputs = [
      self."ml-dtypes"
      self.numpy
      self.opt-einsum
      self.scipy
    ];
  };
  "ml-dtypes" = super.buildPythonPackage rec {
    pname = "ml_dtypes";
    version = "0.2.0";
    format = "pyproject";
    src = super.fetchPypi {
      inherit pname version;
      sha256 = "6488eb642acaaf08d8020f6de0a38acee7ac324c1e6e92ee0c0fea42422cb797";
    };
    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace "numpy~=1.21.2" "numpy" \
        --replace "numpy~=1.23.3" "numpy" \
        --replace "pybind11~=2.10.0" "pybind11" \
        --replace "setuptools~=67.6.0" "setuptools"
    '';
    nativeBuildInputs = [
      self.setuptools
      self.pybind11
    ];
    propagatedBuildInputs = [
      self.numpy
    ];
  };
}
