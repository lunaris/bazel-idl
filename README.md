# bazel-idl

This repository gives an example of how Bazel might be used to manage and build
a monorepo containing multiple microservices, where service-to-service
interaction is not facilitated by shared code, but by (potentially duplicated)
code generated from shared specifications defined using some _interface
description language_ (IDL). The repository is laid out as follows (note, this
is not alphabetical but is an attempt at a logical ordering):

```
.
├── README.md
      This file.

├── WORKSPACE
      Defines the Bazel workspace. Imports rules for dealing with Nixpkgs and
      Haskell projects and defines a Nix-backed GHC toolchain and packageset for
      compiling code. The version of Nixpkgs is pinned, so bumping this
      (accomplished by changing the hash specified in the nixpkgs/default.nix
      file) is akin to bumping a Stackage LTS or nightly version in the
      stack.yaml currently.

├── BUILD.bazel
      Borrowing object oriented terminology, the WORKSPACE is for defining
      "static" things at the top level; BUILD.bazel files (previously BUILD
      files -- Bazel still accepts both) can be thought of perhaps as allowing
      one to define "instance" things. This file just defines a single top-level
      target, which is the compiler (GHC) target we wish to use to build other
      packages.

├── nixpkgs
      The nixpkgs directory contains files pertaining to the Nix subsystem that
      enforces the wider "hermetic seal" around Bazel -- pinning things like the
      C compiler and library being used, the Haskell compiler and other system
      libraries.

│   ├── BUILD.bazel
          This file is empty but its presence means we can talk about the
          nixpkgs directory like a package, referring to its files using paths
          like //nixpkgs:some-file. If this wasn't here, these would be files in
          nested subdirectories of the root package -- //:nixpkgs/some-file, for
          instance -- which is a little uglier in the author's opinion.

│   ├── default.nix
          This just contains a hash specifiying an exact commit of Nixpkgs that
          we want to use. It is referenced both by a repository rule in
          WORKSPACE and by the shell.nix in the root directory (which can be
          used to boot into the Nix environment specified by that hash)

│   └── haskell-packages.nix
          This file contains a Nix expression that defines a set of Haskell
          packages taken from Nixpkgs and potentially other sources (e.g. Github
          repositories, local checkouts, etc.). This is used by the Haskell
          rules in WORKSPACE to make Nix packages visible to Bazel so that we
          can, for example, build something like @hackage//:text and have it
          trigger a usage of the current package on Nix.

├── shell.nix
      As mentioned above, this permits running nix-shell and booting into the
      pinned-Nixpkgs environment.

├── tools
      This directory contains tools that we'll use in the build/infrastructure
      process.

│   ├── avro.sh
          This is the only such "tool" for this example repository. It's a shell
          script that outputs some fairly hard-coded Haskell to simulate what
          having a real IDL-backed code generator might do.

│   └── BUILD.bazel
          As with the nixpkgs/BUILD.bazel, this file largely exists to denote a
          package from which we can refer to the avro.sh tool.

├── bazel
      This directory contains Bazel scripts and macros that we can define to
      provide a build-DSL appropriate to our repository.

│   ├── BUILD.bazel
│   └── haskell.bzl
          In this case, the haskell.bzl is the only such Bazel file, defining a
          rule haskell_avro_library that creates a way of "generating Haskell
          code from a specification defined in the Avro IDL". The quotes are
          added because as noted, this is not actually what happens (the Bash
          script is garbage) but the effect is the same -- a Bazel rule defines
          some input [IDL], an output [generated Haskell] and then links that
          into a Haskell library that other targets can depend on.

├── accounts
      Defines an accounts package. For simplicity, this package doesn't actually
      define any Haskell modules; it just exposes an IDL. Its BUILD.bazel
      defines an api target that perhaps would be used to implement a cqrs-like
      package, but this is only visible inside the package (the default
      visibility for all targets is private). Only the IDL is made public using
      the export_files directive. This means that other packages can use that
      IDL to generate their own (potentially duplicated) code and build against
      the shared contract it represents.

│   ├── accounts.idl
│   └── BUILD.bazel

├── profiles
      Defines a profiles package. Depends on the //accounts:accounts.idl and its
      own IDL to define two api packages, which are then both imported
      "magically" in the Test.hs file. If the accounts IDL is changed, all of
      this will be rebuilt.

│   ├── BUILD.bazel
│   ├── profiles.idl
│   └── Test.hs
.
```

## Playing around/commands

_Note: You should have Nix installed for these to work, but beyond that Nix
should take care of everything else. If it doesn't, please file an issue!_
Your life will be easier though if you install `direnv` as well.


### With direnv

The first time you `cd` to the directory, tell `direnv` that you trust the
`.envrc` file:

```
$ direnv allow .
```

Build everything:

```
$ bazel build //...
```

Launch GHCi in the CQRS implementation of the profiles package:

```
$ bazel run //profiles:cqrs@repl
```

### Without direnv

Because `direnv` will put all binaries provided by `nix` (including `bazel`) in
the path, if you don't use `direnv`, you will have to run `bazel` through
`nix-shell` manually.

Build everything:

```
$ nix-shell --pure --run "bazel build //..."
```

Launch GHCi in the CQRS implementation of the profiles package:

```
$ nix-shell --pure --run "bazel run //profiles:cqrs@repl"
```
