# Episode 0 Script

## Begin

From the last episode, you have heard the terminology Bazel **package** and **target**, which are two of the most important concepts in Bazel. However, you might still not know the exact definition of these terminologies. To understand these terminologies is very necessary for you to correctly write Bazel code.

Let's check them out in this video.

## Rule and Target

### What is rule?

A rule in Bazel is a fundamental building block that defines how to produce output files from the input files or rule arguments.

For C or C++ developers, you must have tried to compile a static library with gcc command line that takes a C++ file in and then generates a `.a` file. A `cc_library` rule wraps this procedure as a rule that makes your life easier.

The typical input interfaces of a rule includes `name`, `srcs`, `visibility` and `deps`.

The way to use a rule is to **instantiate** it as target in the BUILD files by passing the input interface.

If we look at BUILD file. We see one target with name `libfoo`, which is an instantiation of rule `cc_library` with the provided sources file and header files. Another target with name `main`, which is an instantiation of rule `cc_binary`. Now we can lead to a one definition of a target: target is the instantiation of a rule.

```python
cc_library(
    name = "libfoo",
    srcs = ["libfoo/foo.cpp"],
    hdrs = ["libfoo/foo.h"],
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "main",
    srcs = ["main.cpp"],
    visibility = ["//visibility:public"],
    deps = [":libfoo"],
)
```

Another type of Bazel target is **files**. For example, the `foo.cpp`, `foo.h` are targets. You don't need to explicitly define a file target, since a file can always be reachable as a target when it is under the management of a BUILD file.

### What is package?

A package is directory containing a BUILD.bazel file that groups related files together. The all the rule targets defined in a BUILD file and all the file targets at the same directory level or in the subdirectories are scoped within this BUILD file, except the subdirectories have a BUILD file.

An intuitive example is the package `//cpp/tests` is an independent package, not scoped by the BUILD file in its parent folder. Due to this, you cannot use relative path to denote the `//cpp:libfoo`.

### What is label?

A label is the uniuqe "identifier of a target". The typical format is `@repository//package_path:target_name`. It can be divided as three parts: repo name, package path and target name.

Let's look at several examples `//cpp:main` and `@googletest//:gtest_main` and `libfoo/foo.cpp`.

`//` or `@googletest` denotes the repository name. When a target of the current repository is being referred to, only `//` is enough. When a target from another repo is being referred to, you have to specify the repo name with `@` as prefix, like the `@googletest`.

The package name is the directory path of its BUILD file. If the package is at the repository root, the path will be empty, as you see in `@googletest//:gtest_main`.

You can use the relative label instead of the full label if a target of the same package is being referred to. For example, `//cpp:libfoo` in `cpp/BUILD.bazel` can be shortened as `:libfoo` or `libfoo`, and `//cpp:libfoo/foo.cpp` can be shorted as `libfoo/foo.cpp`.

### How a Rule is implemented?

[cc_binary](https://github.com/bazelbuild/bazel/blob/master/src/main/starlark/builtins_bzl/common/cc/cc_binary.bzl)

The starlark built-in `cc_common`'s API is declared in `src/main/java/com/google/devtools/build/lib/starlarkbuildapi/cpp/CcModuleApi.java` and implemented in `src/main/java/com/google/devtools/build/lib/rules/cpp/CcModule.java`.

### Write My Own Rule

## Repository Rule and Module Rule

Use Bazel buildifier as an example.
