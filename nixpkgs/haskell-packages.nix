with import <nixpkgs> {};

let
  genBazelBuild =
    callPackage <bazel_haskell_wrapper> {};

  rawHaskellPackages = haskell.packages.ghc862;
in {
  haskellPackages = genBazelBuild rawHaskellPackages;
}
