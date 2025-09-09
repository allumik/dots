# Use local tarball, as authentification from GitHub 
# is more difficult than just copying the file to a new computer

tacseqApp = pkgs.rPackages.buildRPackage {
  name = "tacseqApp";
  # src = pkgs.fetchTarball ~/Documents/Projects/git/tacseqApp-1.1.4.tar.gz;
  src = pkgs.fetchFromGitHub {
    owner = "seqinfo";
    repo = "tacseqApp";
    rev = "f5af7ada6f419382415335f5ae283f8a4643f79c";
    sha256 = "ODIRNRKsqBOqrOINQpOBOET5izKmhnp2F8DCVl4BOQI=";
  };
};
