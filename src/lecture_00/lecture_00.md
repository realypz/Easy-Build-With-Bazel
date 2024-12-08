# Lecture 0. Introduction

## Goal

- Know the basic bazel project structures. Bazel files, how to build and run with simple examples.
- Know the basic bazel commands.
- Witness the bazel cache and bazel actions.

## Install Bazel

You can install a specific version of Bazel for your whole machine and use it.

Alternatively, you can install [Bazelisk](https://github.com/bazelbuild/bazelisk), which automatically downloads, installs and invokes the appropriate version of Bazel executable.

**Bazelisk is the officially recommended way to install Bazel**. Read [Installing Bazel](https://bazel.build/install) for more info.

## Project Layout

```shell
├── MODULE.bazel
├── cpp
│   ├── BUILD.bazel
│   ├── libfoo
│   │   ├── foo.cpp
│   │   └── foo.h
│   ├── main.cpp
│   └── tests
│       ├── BUILD.bazel
│       └── test_foo.cpp
├── go
│   ├── BUILD.bazel
│   ├── foo.go
│   └── my_main.go
├── java
│   ├── BUILD.bazel
│   ├── hello_world.java
│   └── libfoo
│       └── Foo.java
├── python
│   ├── BUILD.bazel
│   ├── libfoo
│   │   ├── __init__.py
│   │   └── foo.py
│   └── main.py
└── rust
    ├── BUILD.bazel
    ├── foo
    │   └── foo.rs
    └── main.rs
```

## Basic Concepts of Bazel

- A `MODULE.bazel` is created at the root of a Bazel [repo](https://bazel.build/concepts/build-ref#repositories).
  The repo with name `play_bazel` is declared as `module(name = "play_bazel")`.

- `BUILD.bazel` file is used to declare a Bazel [package](https://bazel.build/concepts/build-ref#packages).

    Package is a collection of targets. Unlike the `MODULE.bazel` file, the `BUILD.bazel` file can exist many instances.

    E.g. `<repo_root>/cpp/BUILD.bazel` declares the package `//cpp`. `<repo_root>/cpp/tests/BUILD.bazel` declares the package `//cpp/tests`, which is a **subpackage** of `//cpp`.

- `*.bzl` files are used to define bazel rules, macros. The syntax is Starlark, similar to Python.

## Basic Commands

**OBS:** You can use either `bazel` or `bazelisk` in the command line. `bazelisk` will invoke the latest version, or the [specified bazel version for your project](https://github.com/bazelbuild/bazelisk?tab=readme-ov-file#how-does-bazelisk-know-which-bazel-version-to-run).

This tutorial will use `bazelisk` everywhere.

1. Build target(s)

    ```shell
    bazelisk build <target>
    bazelisk build //... # which builds all the targets of this repo 
    ```

2. Run an exectuable target

    ```shell
    bazelisk run //cpp:main
    bazelisk run //java:MyFirstJavaProgram
    ```

3. Build and run a test target

    ```shell
    bazelisk test //cpp/tests:testfoo
    ```

The `bazel build` command is executed by grannular steps which is observable from the bazel console printing.

The output files of a `bazel build` command are cached and can be reused for other bazel commaneds.

A typical example is that `bazel build //cpp:libfoo` is a dependency of `bazel build //cpp/tests:testfoo`. When `testfoo`, the building command will decompose the building steps, and one of the decomposed steps is building `libfoo`. If Bazel detects the generated static libarary of `libfoo` exists and keeps to update in the cache folder, Bazel will reuse it instead of a cleaning build.
