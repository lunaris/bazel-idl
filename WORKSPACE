workspace(name = "bazel_idl")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

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

nixpkgs_local_repository(
    name = "nixpkgs",
    nix_file = "//nixpkgs:default.nix",
)

http_archive(
    name = "io_tweag_rules_haskell",
    strip_prefix = "rules_haskell-f2f256d2b6725cd5b3c43b2946037dfecfb4fc0d",
    urls = ["https://github.com/tweag/rules_haskell/archive/f2f256d2b6725cd5b3c43b2946037dfecfb4fc0d.tar.gz"],
)

load("@io_tweag_rules_haskell//haskell:repositories.bzl", "haskell_repositories")
haskell_repositories()

nixpkgs_package(
  name = "ghc",
  repositories = {"nixpkgs": "@nixpkgs//:default.nix"},
  attribute_path = "haskell.compiler.ghc862",
)

register_toolchains("//:ghc")

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
