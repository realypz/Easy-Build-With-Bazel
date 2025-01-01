"""
Download the Bazel Buildifier tool and export it as an executable target.

Commandline usage:
bazelisk run @buildifier -- -r ./
"""

load(
    "//bazel_buildifier/private:buildifier_urls.bzl",
    "BUILDIFIER_URLS",
)
load(
    "//bazel_buildifier/private:os_arch.bzl",
    "get_os_arch_pair",
)

def _impl(rctx):
    os, arch = get_os_arch_pair(rctx)

    executable_name = rctx.attr.executable_name

    rctx.download(
        url = BUILDIFIER_URLS[(os, arch)]["url"],
        output = executable_name,
        sha256 = BUILDIFIER_URLS[(os, arch)]["sha256"],
        executable = True,
    )

    # Makes the file target has public visibility
    build_file_content = """exports_files(["{}"])""".format(executable_name)

    rctx.file(
        "BUILD.bazel",
        content = build_file_content,
        executable = False,
    )

buildifier_repo = repository_rule(
    implementation = _impl,
    attrs = {
        "executable_name": attr.string(mandatory = True),
    },
)
