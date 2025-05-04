# Lecture 04: Toolchain

This doc was created in May 2025 using **Bazel 8.x** and **Bazel MODULE** (not WORKSPACE).

## 1. The scenarios needing toolchain

When you want to the **actions** to be different. Some typical scenario:

* Use another compiler or linker, instead of what Bazel decides for you
* Build the same source files for a different target platform

These scenarios above would require actions can be switched by the user of the build system, without modifying the target to-be-built.

**A set of parameters that affect the rule's actions is called "toolchain".**

```txt
                          Parameters --------
                                            |
                                       ▪▪▪▪▪▪▪▪▪▪▪
Target to-be built (Source Files) ==>  ▮ Actions ▮ ==> Output Files
                                       ▪▪▪▪▪▪▪▪▪▪▪
```

## 2. Write Toolchain

### 2.1. C/C++

See an example of how I create a C++ toolchain using the Homebrew LLVM on my host in [llvm_toolchain/darwin/BUILD.bazel](llvm_toolchain/darwin/BUILD.bazel):

#### 2.1.1. Rule `cc_toolchain`

* The rule [`cc_toolchain`](https://bazel.build/reference/be/c-cpp#cc_toolchain) is a language-specific toolchain rule for C++, implemented in <https://github.com/bazelbuild/bazel/blob/master/src/main/starlark/builtins_bzl/common/cc/cc_toolchain.bzl>.

* The most important input argument for this target is **`toolchain_config`: "the label of the rule providing `CcToolchainConfigInfo`"**, as documented by the [API of `cc_toolchain`](https://bazel.build/reference/be/c-cpp#cc_toolchain).

* In my example of [llvm_toolchain/darwin/BUILD.bazel](llvm_toolchain/darwin/BUILD.bazel), I borrow the rule `cc_toolchain_config` from `@bazel_tools//tools/cpp:unix_cc_toolchain_config.bzl` to create such target.

* **You definitely have the flexibility to write your own rule that returns the the provider [`CcToolchainConfigInfo`](https://bazel.build/rules/lib/providers/CcToolchainConfigInfo)**. Such rule shall return [`cc_common.create_cc_toolchain_config_info(...)`](https://bazel.build/rules/lib/toplevel/cc_common#create_cc_toolchain_config_info) in the rule implementation, just like [this tutorial](https://bazel.build/tutorials/ccp-toolchain-config) does.

#### 2.1.2. Rule `toolchain`

The rule [`toolchain`](https://bazel.build/reference/be/platforms-and-toolchains#toolchain) is a top-level toolchain target depending on the language specific toolchain target. The important input args are:

* `exec_compatible_with` and `target_compatible_with`: Specifying the constraints of the host and target platform. These two fields would be very useful if you want to create a cross compiler toolchain.

* `toolchain`: The label of a target that returns [`ToolchainInfo`](https://bazel.build/rules/lib/providers/ToolchainInfo.html). In this example, it is the target of rule `cc_toolchain`.

* `toolchain_type`: A tag to specify the toolchain type. Shall always be `@bazel_tools//tools/cpp:toolchain_type` for C/C++ toolchains.

All language-specific toolchain rules shall return [`ToolchainInfo`](https://bazel.build/rules/lib/providers/ToolchainInfo.html) as part of its provider.

### 2.2. Python

See example of using the host system built-in python: [python_toolchain/BUILD.bazel](python_toolchain/BUILD.bazel).

The pattern looks similar to how you write a C++ toolchain:

* `py_runtime_pair` is a rule that returns `platform_common.ToolchainInfo` as provider. See <https://github.com/bazel-contrib/rules_python/blob/main/python/private/py_runtime_pair_rule.bzl>.

* `toolchain` is top level toolchain target which depends on the target of rule `py_runtime_pair`. The `toolchain_type` here is `@rules_python//python:toolchain_type` instead.

### 2.3. Customized Programming Langeuage Rule

The steps are summarized from [Bazel page: Toolchains](https://bazel.build/extending/toolchains).

1. Write the language target rule `bar_binary` in a `*.bzl` file, e.g. `bar_binary.bzl`
2. Write your own toolchain rule `bar_toolchain` in a `*.bzl` file, e.g. `bar_toolchain.bzl`.
   This rule shall return `ToolchainInfo` or `platform_common.ToolchainInfo`.

   ```bazel
    def _bar_toolchain_impl(ctx):
        toolchain_info = platform_common.ToolchainInfo(
            barcinfo = BarcInfo(
                compiler_path = ctx.attr.compiler_path,
                system_lib = ctx.attr.system_lib,
                arch_flags = ctx.attr.arch_flags,
            ),
        )
        return [toolchain_info]

    bar_toolchain = rule(
        implementation = _bar_toolchain_impl,
        attrs = {
            "compiler_path": attr.string(),
            "system_lib": attr.string(),
            "arch_flags": attr.string_list(),
        },
    )
   ```

3. Define a `toolchain_type` target with name `BAR_TOOLCHAIN_TYPE`.

4. Write a `BUILD.bazel` that instantiates the toolchain targets. Example as below.

    ```bazel
    load("<package>:bar_toolchain.bzl", "bar_toolchain")
    load("<package>:bar_toolchain.bzl", "BAR_TOOLCHAIN_TYPE")

    bar_toolchain(
        name = "barc_linux",
        arch_flags = [
            "--arch=Linux",
            "--debug_everything",
        ],
        compiler_path = "/path/to/barc/on/linux",
        system_lib = "/usr/lib/libbarc.so",
    )

    bar_toolchain(
        name = "barc_windows",
        arch_flags = [
            "--arch=Windows",
            # Different flags, no debug support on windows.
        ],
        compiler_path = "C:\\path\\on\\windows\\barc.exe",
        system_lib = "C:\\path\\on\\windows\\barclib.dll",
    )

    toolchain(
        name = "barc_linux_toolchain",
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        toolchain = ":barc_linux",
        toolchain_type = BAR_TOOLCHAIN_TYPE,
    )

    toolchain(
        name = "barc_windows_toolchain",
        exec_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        target_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        toolchain = ":barc_windows",
        toolchain_type = BAR_TOOLCHAIN_TYPE,
    )
    ```

## 3. Use Toolchain in a Build

### 3.1. Register Toolchain

#### 3.1.1. Method 1: Register a toolchain in `MODULE.bazel`

Example:

```bazel
register_toolchains(
    "//llvm_toolchain/darwin:homebrew_llvm",
)
```

#### 3.1.2. Method 2: Pass the toolchain by passing `--extra_toolchains`

Example: `bazelisk build --extra_toolchains=//llvm_toolchain/darwin:homebrew_llvm //cpp:ex0`

### 3.2. Toolchain Resolution

If multiple valid toolchains are registered, **only one** toolchain will be selected among them. Read section [Toolchain resolution](https://bazel.build/extending/toolchains#toolchain-resolution) for details.

You can monitor the toolchain resolution by passing `--toolchain_resolution_debug=<toolchain_type>`.

E.g.

```sh
bazelisk build //cpp:ex0 --toolchain_resolution_debug="@bazel_tools//tools/cpp:toolchain_type"

bazelisk run //python:ex1 --toolchain_resolution_debug="@bazel_tools//tools/python:toolchain_type"
```

## 4. Default Toolchains Generation

### 4.1. Preknowledge About External deps

1. Change directory to the root of your Bazel project, the command `bazelisk info base` prints the path of `output_base` directory.

   This directory is where Bazel stores all build outputs, caches, and temporary files for your project.

2. All the external dependencies repositiories (regardless a direct depdency or indirect dependency) are stored in `<output_base>/external`.

3. Bazel heavily uses the module extension and repository rule from external dependencies (such as `@rules_cc` and `@rules_python`) to auto-generate the default toolchains. This implies `<output_base>/external` is the directory for toolchain inspection.

### 4.2. Default C++ Toolchain Generation

1. The external dependency [`@rules_cc`](https://github.com/bazelbuild/rules_cc) includes rules for C/C++ target and toolchains.

2. `@rules_cc` will be automatically part of your dependency graph in `MODULE.bazel.lock` file. You can still explicitly declare it in `MODULE.bazel` file in your own project.

3. `<output_base>/external/rules_cc+/MODULE.bazel` is important since it invokes the module extension that generates the repository for default toolchains.

4. `<output_base>/external/rules_cc+/MODULE.bazel` calls `register_toolchains("@local_config_cc_toolchains//:all")` to register the auto-generated toolchain.

5. The path of the auto-generated repo `@local_config_cc_toolchains` is `<output_base>/external/rules_cc++cc_configure_extension+local_config_cc_toolchains`.

Based on the information above, you can trace to the top-level `BUILD.bazel` file of repo `@local_config_cc_toolchains`. This is where the default auto-generated toolchain stays.

### 4.3. Default Python Toolchain Generation

Similar as C++ toolchain, you can see three python related repos in `<output_base>/external`:

#### 4.3.1. `rules_python+`

This is the repo path for external dependency [`@rules_python`](https://github.com/bazel-contrib/rules_python). Note the line `register_toolchains("@pythons_hub//:all")` in `rules_python+/MODULE.bazel`.

#### 4.3.2. `rules_python++internal_deps+rules_python_internal`

The repository is internally created by `<output_base>/external/rules_python+/MODULE.bazel`.

#### 4.3.3. `rules_python++python+pythons_hub`

The top level BUILD file in this directory contains many calls of the macro `py_toolchain_suite`, which of each generates a python toolchain of specific version and target platform (including platforms not same as your host platform).

The implementation of `py_toolchain_suite`is in `<output_base>/external/rules_python+/python/private/py_toolchain_suite.bzl`.

The following call of **`native.toolchain`** with **`toolchain_type = TARGET_TOOLCHAIN_TYPE`** is exactly where the toolchain target is created.

```bazel
    native.toolchain(
        name = "{prefix}_toolchain".format(prefix = prefix),
        toolchain = "@{runtime_repo_name}//:python_runtimes".format(
            runtime_repo_name = runtime_repo_name,
        ),
        toolchain_type = TARGET_TOOLCHAIN_TYPE,
        target_settings = target_settings,
        target_compatible_with = target_compatible_with,
    )
```

#### 4.3.4. `rules_python++python+python_3_11_aarch64-apple-darwin`

This directory contains the python interpreter being auto downloaded. It is also auto generated by some repository rule called in some module extension. (I don't spend more time to find which repository rule, but it must be tracable in `@rules_python`).

The suffix describes the target platform I'm using.
