"""Bazel Buildifier module extension."""

load("//bazel_buildifier:repo_rule.bzl", "buildifier_repo")

def _impl_complex(module_ctx):
    created_repo_names = []
    repos_created = 0

    for mod in module_ctx.modules:
        # buildifier: disable=print
        print("Invoked by module: {}".format(mod.name))
        for initialize_tag in mod.tags.initialize:
            repo_name = initialize_tag.repo_name

            # buildifier: disable=print
            print("  Try to create Bazel Buildifier repo \"{}\" in module \"{}\"".format(
                initialize_tag.repo_name,
                mod.name,
            ))

            if repo_name in created_repo_names:
                # buildifier: disable=print
                print("  Repo {} already created. Won't be created again.".format(repo_name))

                # NOTE: Bazel does not allow repo of the same name to be created multiple times.

            else:
                # buildifier: disable=print
                print("  Repo {} created".format(repo_name))
                created_repo_names.append(repo_name)

                buildifier_repo(
                    # NOTE: Enforce the name of the repo is the same as the executable target name
                    #       Thus you can use `bazelisk run @<repo_name>` to run the executable
                    #       instead of `bazelisk run @<repo_name>//:<executable_name>`
                    name = repo_name,
                    executable_name = repo_name,
                )

                repos_created += 1

    # buildifier: disable=print
    print("Total repos created by module extension: {}".format(repos_created))

_initialize = tag_class(
    attrs = {
        "repo_name": attr.string(
            doc = "The Bazel Buildifier repo",
            mandatory = True,
        ),
    },
)

buildifier_module_ext_complex = module_extension(
    doc = """The complex version allows creating multiple buildifier repos.
             for all the modules that use this extension.
             You can sepecify the repo names in the `initialize` tag.""",
    implementation = _impl_complex,
    tag_classes = {
        "initialize": _initialize,
    },
)

def _impl_simple(module_ctx):  # buildifier: disable=unused-variable
    # buildifier: disable=print
    print("Creating Bazel Buildifier repo \"buildifier\"")

    buildifier_repo(
        # NOTE: Enforce the name of the repo is the same as the executable target name
        #       Thus you can use `bazelisk run @<repo_name>` to run the executable
        #       instead of `bazelisk run @<repo_name>//:<executable_name>`
        name = "buildifier",
        executable_name = "buildifier",
    )

buildifier_module_ext_simple = module_extension(
    doc = """The simple version allows creating one @buildifier repo
             for all the modules that use this extension.""",
    implementation = _impl_simple,
)
