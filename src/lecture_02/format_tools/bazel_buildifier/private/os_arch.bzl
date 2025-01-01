"""Common utility functions for toolchains."""

OS_NAME_LINUX = "linux"
OS_NAME_MACOS = "darwin"
ARCH_NAME_AMD64 = "amd64"
ARCH_NAME_AARCH64 = "aarch64"

SUPPORTED_TARGETS = [
    (OS_NAME_LINUX, ARCH_NAME_AMD64),
    (OS_NAME_LINUX, ARCH_NAME_AARCH64),
    # (OS_NAME_MACOS, ARCH_NAME_AMD64),
    (OS_NAME_MACOS, ARCH_NAME_AARCH64),
]

def get_os_name(rctx):
    """ Returns the host OS name.

    Args:
        rctx (any): The repository rule context.

    Returns:
        The host OS name.
    """
    name = rctx.os.name
    if name == "linux":
        return OS_NAME_LINUX
    elif name == "mac os x":
        return OS_NAME_MACOS
    fail("Unsupported OS: " + name)

def get_arch_name(rctx):
    """ Returns the host architecture.

    Args:
        rctx (any): The repository rule context.

    Returns:
        The host architecture.
    """
    name = rctx.os.arch
    if name == "amd64":
        return ARCH_NAME_AMD64
    elif name == "aarch64":
        return ARCH_NAME_AARCH64
    fail("Unsupported architecture: " + name)

def get_os_arch_pair(rctx):
    """ Returns the host OS and architecture pair.

    Args:
        rctx (any): The repository_ctx.

    Returns:
        The host OS and architecture pair.
    """
    return (get_os_name(rctx), get_arch_name(rctx))
