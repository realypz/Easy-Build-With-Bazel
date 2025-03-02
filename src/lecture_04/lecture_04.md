# General Knowledge

## Bazel Glossary

https://bazel.google.cn/reference/glossary

## APIS

https://bazel.google.cn/versions/7.0.0/rules/lib/overview?hl=en

https://bazel.google.cn/reference/be/overview

### MODULE.bazel Files

### BUILD.bazel Files

### Rules

### *.bzl files


### Use Constraints to load  Bazel Target

## Toolchains

The toolchain target can also be specified with compatible **exectuion platform** and **target platfrom**.

```Bazel
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
    toolchain_type = ":toolchain_type",
)
```
