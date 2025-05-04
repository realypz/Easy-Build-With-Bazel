"""C++ toolchain configuration for Apple Silicon Darwin (macOS) using LLVM installed by Homebrew."""

load("@bazel_skylib//lib:paths.bzl", "paths")

_NOT_USED = "NOT_USED"

# Adapt this to your host system
_LLVM_DIR = "/opt/homebrew/opt/llvm"
_LLVM_MAJOR_VERSION = 20
_SYSROOT = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"

LLVM_TOOLCHAIN_DICT = {
    "cpu": _NOT_USED,  # "darwin",
    "compiler": _NOT_USED,  # "clang",
    "host_system_name": _NOT_USED,  # "aarch64",
    "target_system_name": _NOT_USED,  # "aarch64-apple-macosx"
    "target_libc": "macosx",
    "abi_version": _NOT_USED,  # "darwin_aarch64",
    "abi_libc_version": _NOT_USED,  # "darwin_aarch64",
    "cxx_builtin_include_directories": [
        paths.join(_LLVM_DIR, "include/c++/v1"),
        paths.join(_LLVM_DIR, "lib/clang/{}/include".format(_LLVM_MAJOR_VERSION)),
        paths.join(_SYSROOT, "usr/include"),
        paths.join(_SYSROOT, "System/Library/Frameworks"),
    ],
    "tool_paths": {
        "ar": paths.join(_LLVM_DIR, "bin/llvm-libtool-darwin"),
        "cpp": paths.join(_LLVM_DIR, "bin/clang-cpp"),
        "gcc": paths.join(_LLVM_DIR, "bin/clang"),
        "ld": paths.join(_LLVM_DIR, "bin/lld"),
        "llvm-cov": paths.join(_LLVM_DIR, "bin/llvm-cov"),
        "nm": paths.join(_LLVM_DIR, "bin/llvm-nm"),
        "objcopy": paths.join(_LLVM_DIR, "bin/llvm-objcopy"),
        "objdump": paths.join(_LLVM_DIR, "bin/objdump"),
        "strip": paths.join(_LLVM_DIR, "bin/llvm-strip"),
    },
    "compile_flags": [
        # "--target=aarch64-apple-macosx",
        # Security
        "-U_FORTIFY_SOURCE",  # https://github.com/google/sanitizers/issues/247
        "-fstack-protector",
        "-fno-omit-frame-pointer",
        # Diagnostics
        "-fcolor-diagnostics",
        "-Wall",
        "-Wthread-safety",
        "-Wself-assign",
        "-fno-define-target-os-macros",  # Prevents the definition of TARGET_OS_OSX
    ],
    "dbg_compile_flags": ["-g", "-fstandalone-debug"],
    "opt_compile_flags": [
        "-g0",
        "-O2",
        "-D_FORTIFY_SOURCE=1",
        "-DNDEBUG",
        "-ffunction-sections",
        "-fdata-sections",
    ],
    "cxx_flags": [
        "-std=c++20",  # Will be overriden by bazel command line arg `--cxxopt="-std=c++<standard>"`
        "-stdlib=libc++",
    ],
    "link_flags": [
        # "--target=aarch64-apple-macosx", # NOTE: Disabled now. It seems you can pass any arbitrary string.
        "-no-canonical-prefixes",
        "-headerpad_max_install_names",
        "-fobjc-link-runtime",
        # -l<library> for linking
        #"-Bdynamic_t",

        # The -Bstatic option is used to instruct the linker to prefer static linking for libraries that follow this option.
        "-Bstatic",
        "-lc++",
        "-lc++abi",
        "-L" + paths.join(_LLVM_DIR, "lib"),
        "-L" + paths.join(_LLVM_DIR, "lib/unwind"),
        "-lunwind",  # Enable this will link to /opt/homebrew/opt/llvm/lib/libunwind.1.dylib, otherwise the macOS internal unwinder
        "-fuse-ld=lld",  # This will use llvm lld as linker, as opposed of the macOS's ld
        # "-lm", # TODO: link math library.Disable for now, not necessary at the moment.
        # "-L/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib",  # Or equivalent as `--library-directory=<lib>`
    ],
    "archive_flags": ["-static"],
    "link_libs": [],
    "opt_link_flags": [],
    "unfiltered_compile_flags": [
        "-no-canonical-prefixes",
        "-Wno-builtin-macro-redefined",
        "-D__DATE__=\"redacted\"",
        "-D__TIMESTAMP__=\"redacted\"",
        "-D__TIME__=\"redacted\"",
    ],
    "coverage_compile_flags": ["-fprofile-instr-generate", "-fcoverage-mapping"],
    "coverage_link_flags": ["-fprofile-instr-generate"],
    "supports_start_end_lib": False,
    "builtin_sysroot": _SYSROOT,
}
