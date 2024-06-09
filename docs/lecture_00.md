# Lecture 0. Getting Start

## Install Bazel

You can install a specific version of Bazel for your whole machine and use it.

Alternatively, you can install [Bazelisk](https://github.com/bazelbuild/bazelisk), which automatically downloads, installs and invokes the appropriate version of Bazel executable.

**Bazelisk is the officially recommended way to install Bazel**. Read [Installing Bazel](https://bazel.build/install) for more info.

## Project Layout

```shell
├── MODULE.bazel
├── README.md
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

* A `MODULE.bazel` is created at the root of a Bazel [repo](https://bazel.build/concepts/build-ref#repositories).
  The repo with name `play_bazel` is declared as `module(name = "play_bazel")`.

* `BUILD.bazel` file is used to declare a Bazel [package](https://bazel.build/concepts/build-ref#packages).

    E.g. `<repo_root>/cpp/BUILD.bazel` declares the package `//cpp`. `<repo_root>/cpp/tests/BUILD.bazel` declares the package `//cpp/tests`, which is a **subpackage** of `//cpp`.

    All the files and subdirectories under `<repo_root>/cpp` belong to the package `//cpp`, but the subpackage `//cpp/tests` and everything beneth the subpackage do not.

* A Bazel [target](https://bazel.build/concepts/build-ref#targets) is defined in the package's `BUILD.bazel` file.

  Most targets are one of the two types, files and instance of some rule. E.g.
  * `//cpp:main` is a instance of rule `cc_binary`. `//cpp/tests:testfoo` is an instance of rule `cc_test`.
  * `//cpp:main.cpp` or `//cpp:libfoo/foo.h` is a file.
  
* The identifier of a target is [label](https://bazel.build/rules/lib/builtins/Label).

  A label consists of three parts: the repo name, package name and target name.

  In the label `//cpp/tests:testfoo`
  * Since the label is used in the same repo, the repo name is omitted. The label with repo name is `@play_bazel//cpp/tests:testfoo`, where the repo name is defined in `MODULE.bazel`.
  * `cpp/tests` represents the package name (which is aligned with the relative directory path)
  * `testfoo` is the target name. `:` is used to separate the package name and target name.

  The labels of the targets referred within the same pacakge can be abbreviated.
  
  E.g. Within `cpp/BUILD.bazel`, target `//cpp:libfoo/foo.h` can be abbreviated as `libfoo/foo.h` or `:libfoo/foo.h`, target `//cpp:libfoo` can be abbreviated as `libfoo` or `:libfoo`.

## Basic Commands

**OBS:** You can use both `bazel` and `bazelisk` in the command line. `bazelisk` will invoke the latest version, or the [specified bazel version for your project](https://github.com/bazelbuild/bazelisk?tab=readme-ov-file#how-does-bazelisk-know-which-bazel-version-to-run).

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
