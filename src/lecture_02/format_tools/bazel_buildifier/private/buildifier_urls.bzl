"""
Bazel Buildifier urls
"""

load(
    ":os_arch.bzl",
    "ARCH_NAME_AARCH64",
    "ARCH_NAME_AMD64",
    "OS_NAME_LINUX",
    "OS_NAME_MACOS",
)

BUILDIFIER_URLS = {
    (OS_NAME_LINUX, ARCH_NAME_AMD64): {
        "url": "https://github.com/bazelbuild/buildtools/releases/download/v7.3.1/buildifier-linux-amd64",
        "sha256": "5474cc5128a74e806783d54081f581662c4be8ae65022f557e9281ed5dc88009",
    },
    (OS_NAME_LINUX, ARCH_NAME_AARCH64): {
        "url": "https://github.com/bazelbuild/buildtools/releases/download/v7.3.1/buildifier-linux-arm64",
        "sha256": "0bf86c4bfffaf4f08eed77bde5b2082e4ae5039a11e2e8b03984c173c34a561c",
    },
    (OS_NAME_MACOS, ARCH_NAME_AARCH64): {
        "url": "https://github.com/bazelbuild/buildtools/releases/download/v7.3.1/buildifier-darwin-arm64",
        "sha256": "5a6afc6ac7a09f5455ba0b89bd99d5ae23b4174dc5dc9d6c0ed5ce8caac3f813",
    },
}
