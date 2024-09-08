# Episode 0 Script

## Begin

Hi, welcome to the Bazel videos. I know many of you start to use the Bazel building system but struggles with the start, or you have been using Bazel for a while but feel not easy to follow the official documentation.

If that’s how you feel, don’t worry, you are not alone.

After experiencing Bazel for myself, I want to help you enter this Bazel world with the smoothest onboarding, and present the knowledge in the most structured way.

Let’s begin.

## The Bazel Project Layout

Let’s look at a Bazel project. There are three important types you need to know.

First, the `MODULE.bazel` file marks the boundary of your bazel repo, it locates at the repository root. You can declare your repo name, version and the external dependencies being used by this repo.

Second, many `BUILD.bazel` files exist in your project at different location and depth. In Bazel’s terminology, a bazel package is defined as **an directory containing a BUILD file**. Intuitively, you can think a BUILD file as a collection of Bazel targets within the directory marked by a BUILD file.

In a practical example, the directory path `cpp/` is a Bazel package, because it has a `BUILD.bazel` file inside it. I define my C++ targets within this file, and I can build them by `bazel build` command.

BUILD files are the backbone of your code organization in a repository. You will deeply understand this once you gets your hands dirty.

The third file type is `*.bzl` files. These files are used to define custom build rules, macros, and other reusable pieces of build logic. For example, I create the rule `print_in_shell` in this `greeting.bzl` file, then I use this rule in a BUILD file. You might also notice that the syntax in a `.bzl` file is very similar to python. Yes, it is Starlark, a subset of python language.

These three file types are essential for a Bazel project.

## Build C++ Targets

Now it’s the time to look at building in Bazel.

The command is just simple as `bazel build <target>` . For example, I would like to build the `cc_libaray` `libfoo`, I just type `bazel build //cpp:libfoo` in my terminal.

When the build is finished, you can read information print out by bazel, we have 110 packages loaded, 899 targets configured. The static library just built is generated in the cache folder named `bazel-bin`. 5 bazel actions have been executed for this build command.

Next, I would like to build the C++ binary taget `main` . Similarly, the executable `main` just built is generated in the cache folder. I can also run a the binary target by `bazel run` command, then print out of the executable is printed in terminal. 

In the last three steps, I built the C++ library taget, binary taget and ran the binary target in order. What about I ignore the first two steps and run the executable `main` by bazel run command directly? You can surely do that. Before you type `bazel run` command, let’s clean all the bazel cache folders by typing `bazel clean`. Next, we type `bazel run //cpp:main` . After a while, you can see the print out by the executable and and the bazel cache folders.

I can also build the executable multiple times, since the executable has been existing in the cache, nothing will be output to the cache, and no new packages or new targets will be configured, and the action number is only one.

If we pay closer attention the numbers of packages loaded or targets configured, you can see some patterns. Here I summarize the statistics of the three steps of build and run, and a direct run in two tables. The interesting fact is the sum of packages loaded and targets configured are the same between left and right table. And “the number of actions” minus “how many bazel command you entered” are be the same.

## Summarize

Let’s summarize the video.

We went through a typical layout of a bazel project. The MODULE file marks the root of a Bazel project, the BUILD file is a backbone of where you define targets that organize your source code. The `*.bzl`  files give you possibility to create customized bazel rules and macros.

We also tried the most essential commands `bazel build` and `bazel run` on a C++ tagets. We observed the bazel cache is generated and being used to make the building faster.

If you like my creation, make sure give a like and subscribe. I will see you next time! Cheers!

<!-- 
## What features does Bazel support?

Bazel and CMake are both powerful build systems, but Bazel has some distinct features and capabilities that set it apart. Here are some things Bazel can do that CMake typically cannot or does not do as well:

1. Hermetic Builds:
   Bazel is designed to create fully reproducible builds by strictly controlling inputs and dependencies. This level of hermeticity is harder to achieve with CMake.

2. Multi-Language Support:
   While CMake is primarily focused on C and C++, Bazel natively supports multiple languages (Java, C++, Python, Go, Rust, etc.) in a single build, making it easier to manage polyglot projects.

3. Remote Caching and Execution:
   Bazel has built-in support for remote caching and distributed execution, which can significantly speed up builds in large projects or CI/CD environments.

4. Fine-grained Dependency Management:
   Bazel's dependency model is more granular, allowing for better parallelization and incremental builds.

5. Sandboxed Execution:
   Bazel can run build actions in sandboxes, isolating them from the rest of the system for improved reproducibility and security.

6. External Dependency Management:
   Bazel's MODULE file and repository rules provide a powerful way to manage external dependencies, including the ability to download and build them from source.

7. Built-in Testing Framework:
   Bazel includes a testing framework that works across languages, making it easier to integrate tests into the build process.

8. Query Language:
   Bazel provides a powerful query language for analyzing the build graph, which can be useful for debugging and optimizing builds.

9. Remote Repository Support:
   Bazel can directly reference and use code from remote repositories (like GitHub) without needing to copy it locally first.

10. Aspect-Oriented Build Configurations:
    Bazel's "aspects" allow for adding cross-cutting build logic without modifying existing BUILD files.

11. Advanced Caching:
    Bazel's caching system is more advanced, caching at the action level rather than just at the file level.

12. Skylark/Starlark Language:
    Bazel uses its own domain-specific language (Starlark) for build configuration, which is designed specifically for build systems and is more constrained than CMake's scripting capabilities.

13. Easier Cross-Compilation:
    While both support cross-compilation, Bazel's toolchain model often makes it easier to set up and manage cross-compilation environments.

14. Better Support for Monorepos:
    Bazel is often preferred for very large, multi-project repositories (monorepos) due to its scalability and fine-grained dependency model.

15. Build Performance Analysis:
    Bazel provides built-in tools for analyzing build performance and dependencies, which can be crucial for optimizing large builds. -->
