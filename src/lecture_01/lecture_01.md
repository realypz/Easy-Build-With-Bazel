# Lecture 1: Bazel Target and Rule

## Goal

- Understand the concept of package, label, target and rule.
- Use the cc_binary target as example to see the typical configurable parameters.
- How to write your own rule.

## 1. Package, Target and Label

### `BUILD.bazel` file is used to declare a Bazel [package](https://bazel.build/concepts/build-ref#packages)

E.g. `<repo_root>/cpp/BUILD.bazel` declares the package `//cpp`. `<repo_root>/cpp/tests/BUILD.bazel` declares the package `//cpp/tests`, which is a **subpackage** of `//cpp`.

All the files and subdirectories under `<repo_root>/cpp` belong to the package `//cpp`, but the **subpackage** `//cpp/tests` and everything beneth the subpackage do not.

### A Bazel [target](https://bazel.build/concepts/build-ref#targets) is defined in the package's `BUILD.bazel` file

Two types of targets:

- Instance of a **rule**. E.g. `//cpp:main` is a instance of rule `cc_binary`. `//cpp/tests:testfoo` is an instance of rule `cc_test`.
- A file. E.g. `//cpp:main.cpp` or `//cpp:libfoo/foo.h` is a file.
  
### The unique identifier of a target is [label](https://bazel.build/rules/lib/builtins/Label)

A label consists of three parts: `<repo>//<package_dir>:<target>`.

In the label `//cpp/internal:os_info`

- `//` denotes the current repo.
- `cpp/internal` represents the package directory marked by `<repo_root>/cpp/internal/BUILD.bazel`. `//cpp/internal` (combined with `//`) means a package.
- `os_info` is the target name. `:` is used to separate the package name and target name.

In the label `@googletest//:gtest_main`,

- The repo name is the `googletest`. Since it is a external repo, you have to use `@<repo_name>` to denote.
- The package is at the repo root level, i.e. `<goolge_test_repo_root>/BUILD.bazel`.
- The target name is `gtest_main`.

### Abbreviated Label

- When being referred within the same package, the package part of a label can be omitted.

    e.g. When being referred within `cpp/interal/BUILD.bazel`, target `//cpp/interal:os_info_darwin.cpp` can be referred with abbreviation as `os_info_darwin.cpp` or `:os_info_darwin.cpp`.

- When the target name is the same as package folder name, the target name can be omitted.

    e.g. `//print_os:print_os` can be abbreviated as `//print_os`, `@fmt//:fmt` can be abbreviated as `@fmt`.

## 2. Rule

### 2.1 What is a Rule

>A rule defines a series of **actions** that Bazel performs on **inputs** to produce a set of **outputs**.

For `cc_binary` rule, the **inputs** is a set of `.cpp` or `.cc` files.

The **actions** are:

- Compile all the C++ sources files.
- Link the .o files to an executable.

The **output** is the excutable file.

### 2.2 How to declare a target of a Bazel built-in rule?

Let's take [`cc_binary`](https://bazel.build/reference/be/c-cpp#cc_binary) and [`cc_library`](https://bazel.build/reference/be/c-cpp#cc_library) as example.

```py
# At src/lecture_01/cpp/internal/BUILD.bazel
cc_library(
    name = "os_info",
    srcs =
        select({
            "@platforms//os:osx": ["os_info_darwin.cpp"],
            "@platforms//os:linux": ["os_info_linux.cpp"],
        }),
    hdrs = ["os_info.hpp"],
    visibility = ["//visibility:public"],
)

# At src/lecture_01/cpp/BUILD.bazel
cc_binary(
    name = "hello_boss",
    srcs = ["hello_boss.cpp"],
    cxxopts = [
        "-std=c++23",
        "-O2",
    ],
    defines = ["GREETING_BOSS"],
    includes = ["internal"],
    deps = [
        "//cpp/internal:os_info",
        "@fmt//:fmt",
    ],
)
```

The most important **attributes** for `cc_library`

- name: Target name.
- srcs: The source files, the permitted types are `.c`, `.cpp`, `.h`, `.hpp`, `.S`, `.a` etc.
- hdrs: The header files you would like to be available for other targets depending on this target.
- deps: The other `cc_library` or `objc_library` that this target depends on.
- visibility: To specify whether this target can be used in other packages or not.

Recommend you read how rules for other languages are defined, e.g. [Python Rules](https://bazel.build/reference/be/python), [Java Rules](https://bazel.build/reference/be/java). You can find the **common attributes** to most of the rules, e.g. `name`, `srcs`, `deps`, `visibility`.

Read [Typical attributes defined by most build rules](https://bazel.build/reference/be/common-definitions#typical-attributes) and [Attributes common to all build rules](https://bazel.build/reference/be/common-definitions#common-attributes) for all informations.

### 2.3 Write a Rule

Let's recall the definition of a Rule in Bazel: A rule defines a series of **actions** that Bazel performs on **inputs** to produce a set of **outputs**. Focus on these three terms when reading below.

#### 2.3.1 Rule Implementation in `*.bzl` File

A rule implementation consists of a **rule implementation callback function** and **rule declaraion**. These two are coded in a `*.bzl` file.

```py
## ⬇️⬇️⬇️⬇️⬇️ my_dummy_rule.bzl ⬇️⬇️⬇️⬇️⬇️

def _my_rule_impl(ctx):
    """
    Rule implementation callback function.
    The callback defines the actions to generate the ouputs from the inputs.

    Args:
        ctx: The rule context object (https://bazel.build/rules/lib/builtins/ctx)
             passed to the rule implementation function.
             The most commonly used attributes are:
             ctx.attr, ctx.actions
    """

    ## ++++++ Declare the output files to be created ++++++
    #
    # Bazel requires the rule to explicitly declare all the output files to be created.
    # This helps Bazel understand what files will be produced by the rule, which is essential
    # for dependency tracking and incremental builds.
    # ...

    ## ++++++ Define the actions to be performed ++++++
    #
    # The actions is typically performed by the functions under ctx.actions,
    # e.g. ctx.actions.run,
    #      ctx.actions.run_shell
    #      ctx.actions.expand_template
    # ...

    ## ++++++ Return a provider (https://bazel.build/extending/rules#providers) ++++++
    #
    # Providers are pieces of information that a rule exposes to other rules that depend on it.
    # This data can include output files, libraries, parameters to pass on a tool's command line,
    # or anything else a target's consumers should know about.
    #
    # The most common provider is DefaultInfo.
    # You can also create customized provider by calling `provider` (https://bazel.build/rules/lib/globals/bzl#provider)
    # ...
    pass

# Declare the rule "my_rule"
my_rule = rule(
    implementation = _my_rule_impl,
    attrs = {
        ## ++++++ Attributes ++++++
        # Attributes defined below can be accessed by the callback function by ctx.attr
        # E.g. ctx.attr.foo, ctx.attr.bar
        #
        # `attr` is a top-level module (https://bazel.build/rules/lib/toplevel/attr) for defining the attribute schemas of a rule or aspect.
        # The most commonly used members are
        #     attr.string, attr.lablel, attr.label_list
        "foo": attr.string(),
        "bar": attr.label(),
        # ...
    }
)
```

#### 2.3.2 Create a Target of a Rule in `BUILD.bazel`

To create a target of a rule in a `BUILD.bazel` file, you just need to import the `my_rule` from the bazel target.

```py
load("<package>:my_dummy_rule.bzl", "my_rule")

my_rule(
    name = "my_rule_target",
    ## Fill the other attributes defined by the rule below.
    foo = # ...,
    bar = # ...
)

```

### 2.4 A Simple Rule Implementaion Example

A real example is in [`os_info.bzl`](print_os/os_info.bzl): a rule that generate a `*.txt` file with os informatiuon get from `uname --all`.
Then the `cc_binary` instance [`//print_os:print_os`](print_os/BUILD.bazel) reads the `*.txt` and print it out.

```py
## ⬇️⬇️⬇️⬇️⬇️ print_os/BUILD.bazel ⬇️⬇️⬇️⬇️⬇️

load("//print_os:os_info.bzl", "os_info")

os_info(
    name = "osinfo",
    output_file = "os_info_printout.txt",
)

cc_binary(
    name = "print_os",
    srcs = ["print_os.cpp"],
    # You have to explicitly add `osinfo` target in the data attribute
    # to make the binary accssible to the generated file. 
    data = [":osinfo"],
)
```

### 2.5 Bazel Native Rule Implementation

Rather than implementing in Starlark language, Bazel's built-in rule, e.g. `cc_binary` is implemented in java instead, as illustrates in [`src/main/java/com/google/devtools/build/lib/bazel/rules/CcRules.java`](https://github.com/bazelbuild/bazel/blob/master/src/main/java/com/google/devtools/build/lib/bazel/rules/CcRules.java). However, there is a starlark version of [`cc_binary.bzl`](https://github.com/bazelbuild/bazel/blob/master/src/main/starlark/builtins_bzl/common/cc/cc_binary.bzl). And this example can provide insights of how to implement a complex rule.

```py
def _impl(ctx):
    binary_info, providers = cc_binary_impl(ctx, [])

    # We construct DefaultInfo here, as other cc_binary-like rules (cc_test) need
    # a different DefaultInfo.
    providers.append(DefaultInfo(
        files = binary_info.files,
        runfiles = binary_info.runfiles,
        executable = binary_info.executable,
    ))

    # We construct RunEnvironmentInfo here as well.
    providers.append(RunEnvironmentInfo(
        environment = cc_helper.get_expanded_env(ctx, {}),
        # cc_binary does not have env_inherit attr.
        inherited_environment = [],
    ))

    return providers

cc_binary = rule(
    implementation = _impl,
    initializer = dynamic_deps_initializer,
    doc = "...",
    attrs = cc_binary_attrs,
    outputs = {
        "stripped_binary": "%{name}.stripped",
        "dwp_file": "%{name}.dwp",
    },
    fragments = ["cpp"] + semantics.additional_fragments(),
    exec_groups = {
        "cpp_link": exec_group(toolchains = cc_helper.use_cpp_toolchain()),
    },
    toolchains = cc_helper.use_cpp_toolchain() +
                 semantics.get_runtimes_toolchain(),
    provides = [CcInfo],
    executable = True,
)

```

## 3. [Phase of a build](https://bazel.build/run/build#build-phases) (Revision Needed)

### 3.1 Load Phase

Bazel reads and evaluates the build files that define the targets asked to be built, as well as the `BUILD.bazel` and `*.bzl` files of the targets' dependencies. This happens on the machine where Bazel is invoked. The target graph is **cached in memory**.

Errors reported during this phase include (Revision needed):

- package not found, e.g. a typo in the package part of a label.
- target not found, e.g. the wrong target name in a label.
- lexical and grammatical errors BUILD files and `*.bzl` files.
- evaluation errors.

Equivalent command: `bazel query "deps(//print_os)"`, which executes a dependency graph query but not check the validity of dependency graph.

### 3.2 Analysis

Bazel does semantic analysis for the targets and their dependencies to build the **dependency graph** and **action graph**. As with the loading phase, this work happens on the machine where Bazel is invoked, and the action graph is cached in memory.

Errors reported at this stage include:

- inappropriate dependencies (e.g. circular dependency)
- invalid inputs to a rule
- all rule-specific error messages

Equivalent command:

- `bazel cquery "deps(//print_os)"`, which does a post-analysis on the dependency graph (circular dependency, the source files name are checked)
- `bazel aquery "deps(//print_os)"`, executes a query on the post-analysis action graph.

### 3.3 Execute

Bazel determines which files are out of date and executes actions needed to produce them. Actions may be executed locally in a sandbox or remotely using an execution service. The output files are cached, either locally or on a remote caching service.

Errors reported during this phase include: missing source files, errors in a tool executed by some build action, or failure of a tool to produce the expected set of outputs.

Equivalent command: `bazel build //print_os`.

### Practice

Try introduce some artificial errors, e.g. syntax error, typo of target name, circular dependencies and run `bazel query`, `bazel cquery`, `bazel aquery` and `bazel build`, then observe the errors are reported by which command.

## 4. Summary

The definition of package, target, label.

The definition of a rule: inputs, actions and outputs.

Implementation of a rule: the declaration and the implemtation callback.

Three phases of a building command.

## References

[Writing Bazel rules: moving logic to execution](https://jayconrod.com/posts/109/writing-bazel-rules-moving-logic-to-execution)
