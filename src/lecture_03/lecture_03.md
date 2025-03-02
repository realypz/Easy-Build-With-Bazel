# Lecture 03: Platforms

## Goal

How to build platform specific code?

## 1. [Platform Concept](https://bazel.build/extending/platforms)

Bazel recognizes three roles that a platform may serve:

* **Host** - the platform on which Bazel itself runs.
* **Execution** - a platform on which build tools execute build actions to produce intermediate and final outputs.
* **Target** - a platform on which a final output resides and executes.

Bazel supports the following build scenarios regarding platforms:

* **Single-platform builds** (default) - host, execution, and target platforms are the same. For example, building a Linux executable on Ubuntu running on an Intel x64 CPU.
* **Cross-compilation builds** - host and execution platforms are the same, but the target platform is different. For example, building an iOS app on macOS.
* **Multi-platform builds** - host, execution, and target platforms are all different.

> OBS: I believe that the **Multi-platform builds** is only relavant to [**Remote Build Execution**](https://bazel.build/remote/rules). You would be only interested in **Single-platform builds** and **Cross-compilation builds** for the projects built locally without involving remote build.

## 2. Bazel Targets Related to Platforms

### 2.1 Target Describing Individual Constraints

[`constraint_setting`](https://bazel.build/reference/be/platforms-and-toolchains#constraint_setting) target is similar to a **enum class**, and [`constraint_value`](https://bazel.build/reference/be/platforms-and-toolchains#constraint_value) target is similar to the actual enum values beneth the enum class.

E.g. Target [`@platforms//cpu:cpu`](https://github.com/bazelbuild/platforms/blob/main/cpu/BUILD#L14) defines a category CPU. Target [`@platforms//cpu:aarch64`](https://github.com/bazelbuild/platforms/blob/main/cpu/BUILD#L57), [`@platforms//cpu:x86_64`](https://github.com/bazelbuild/platforms/blob/main/cpu/BUILD#L162) are the individual enum values.

### 2.2 Target Describing a Collection of Constraints

A [`platform`](https://bazel.build/reference/be/platforms-and-toolchains#platform) target is a **logical-and** collection of one or several [`constraint_value`](https://bazel.build/reference/be/platforms-and-toolchains#constraint_value) targets, including the `constraint_value`s inherited from a parent `platform` target.

E.g. Target [`@platforms//host:host`](https://github.com/bazelbuild/platforms/blob/main/host/BUILD) is the collection of the CPU and OS type of your host machine.

> OBS: The constraint values in `@platforms//host` are generated on-the-fly by repository rules.

### 2.3 Sample Code

Beyond CPU type and OS type, you can define your own constaint and platform targets.

In `my_platforms/servo_constraint/BUILD.bazel`:

```txt
constraint_setting(
    name = "servo_constraint",
)

constraint_value(
    name = "real",
    constraint_setting = ":servo_constraint",
    visibility = ["//visibility:public"],
)

constraint_value(
    name = "simulated",
    constraint_setting = ":servo_constraint",
    visibility = ["//visibility:public"],
)
```

In `my_platforms/BUILD.bazel`:

```txt
platform(
    name = "simulator",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
        "//my_platforms/servo_constraint:simulated",
    ],
    parents = ["@platforms//host"],
)

platform(
    name = "target",
    constraint_values = [
        "@platforms//os:macos",
        "@platforms//cpu:arm64",
        "//my_platforms/servo_constraint:real",
    ],
)
```

## 3. How to Use Platform and Constraints to build platform specific code?

You can achieve this by specifying something in Bazel targets and the Bazel build command.

### 3.1 Specifiy Platform in Bazel Command

[`--platforms`](https://bazel.build/reference/command-line-reference#flag--platforms): Speciy a `platform` target that representing the **target platform** for the current command. If not explicitly specified, [`@platforms//host`](https://github.com/bazelbuild/platforms/blob/main/host/BUILD) will be used.

The building will fail if at least one constraint specified by `--platforms` is incompatible with the constraints specified by the targets (the direct building target and its dependency targets).

```sh
bazelisk build <library or binary> --platforms=//my_platforms:target
```

### 3.2 Specification in Bazel Targets

One way to apply constraints on a Bazel Target is to specify
[`exec_compatible_with`](https://bazel.build/reference/be/common-definitions#common.exec_compatible_with) and [`target_compatible_with`](https://bazel.build/reference/be/common-definitions#common.target_compatible_with).

```txt
cc_binary(
    name = "hello",
    srcs = ...,
    deps = ...
    exec_compatible_with = <List of `constraint_values`>,
    target_compatible_with = <List of `constraint_values`>,
)
```

The other way is to use [`select`](https://bazel.build/reference/be/functions#select) function to specify the `dependencies`, `srcs` or other fields in the target, or using `select` together with [`alias`](https://bazel.build/reference/be/general#alias).

```txt
cc_binary(
    name = "my_exec",
    srcs = select({
        "@platforms//os:macos": ["macos/foo.cc"],
        "@platforms//os:linux": ["linux/foo.cc"],
    }),
    hdrs = ["foo.hpp"],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "bar_linux",
    hdrs = ["bar.hpp"],
    srcs = ["bar_linux.cpp"],
    target_compatible_with = ["@platforms//os:linux"],
    visibility = ["/visibility:private"],
)

cc_library(
    name = "bar_macos",
    hdrs = ["bar.hpp"],
    srcs = ["bar_macos.cpp"],
    target_compatible_with = ["@platforms//os:macos"],
    visibility = ["/visibility:private"],
)

alias(
    name = "bar",
    actual = select(
        "@platforms//os:macos": ":bar_macos",
        "@platforms//os:linux": ":bar_linux",
    )
)
```
