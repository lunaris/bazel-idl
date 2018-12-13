workspace(name = "bazel_idl")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Load a pinned set of rules for working with Nix repositories.

http_archive(
    name = "io_tweag_rules_nixpkgs",
    sha256 = "e08bfff0e3413cae8549df72e3fce36f7b0e2369e864dfe41d3307ef100500f8",
    strip_prefix = "rules_nixpkgs-0.4.1",
    urls = ["https://github.com/tweag/rules_nixpkgs/archive/v0.4.1.tar.gz"],
)

load(
    "@io_tweag_rules_nixpkgs//nixpkgs:nixpkgs.bzl",
    "nixpkgs_local_repository",
    "nixpkgs_package",
)

# Define a Nix repository as specified by a Nix expression in a
# locally-available file (in contrast there are rules for e.g. using a SHA to
# target the nixpkgs Github repository).

nixpkgs_local_repository(
    name = "nixpkgs",
    nix_file = "//nixpkgs:default.nix",
)

# Load a pinned set of rules for working with Haskell code (building libraries,
# binaries, etc.)

http_archive(
    name = "io_tweag_rules_haskell",
    strip_prefix = "rules_haskell-f2f256d2b6725cd5b3c43b2946037dfecfb4fc0d",
    urls = ["https://github.com/tweag/rules_haskell/archive/f2f256d2b6725cd5b3c43b2946037dfecfb4fc0d.tar.gz"],
)

load("@io_tweag_rules_haskell//haskell:repositories.bzl", "haskell_repositories")
haskell_repositories()

# Define an external repository, @ghc, which exposes a target that builds a
# version of GHC (8.6.2) available in the Nix repository set up earlier. The
# attribute_path is the literal Nix attribute path one would use in "raw Nix".

nixpkgs_package(
  name = "ghc",
  repositories = {"nixpkgs": "@nixpkgs//:default.nix"},
  attribute_path = "haskell.compiler.ghc862",
)

# This is a weird circularity but hey ho. The top-level BUILD.bazel uses the
# @ghc external repository to define a Haskell toolchain using that GHC. We then
# have to register this toolchain in the workspace so that other Haskell rules
# use it. As I say, weird, but that's how it is.

register_toolchains("//:ghc")

# With the toolchain defined, we'll also define a pinned set of Haskell packages
# from Nix. This means we don't have to have the source code for containers,
# text, etc. in our repository to get granular rebuilding/caching -- Nix has
# already got that covered. The basic idea here is that the
# haskell_nixpkgs_packageset takes a file containing a Nix expression defining a
# set of Haskell packages and generates a Bazel external repository reifying
# those packages as Bazel targets. So after we've run the final
# `import_packages` call, we have an external repository, @hackage, which has
# targets for all packages defined in the set. So we can build e.g.
# @hackage//:mtl, @hackage//:transformers, and so on.

load(
    "@io_tweag_rules_haskell//haskell:nix.bzl",
    "haskell_nixpkgs_packageset",
)

haskell_nixpkgs_packageset(
    name = "hackage_packages",
    repositories = {"nixpkgs": "@nixpkgs//:default.nix"},
    nix_file = "//nixpkgs:haskell-packages.nix",
    base_attribute_path = "haskellPackages",
)

load("@hackage_packages//:packages.bzl", "import_packages")

import_packages(
    name = "hackage",
)
