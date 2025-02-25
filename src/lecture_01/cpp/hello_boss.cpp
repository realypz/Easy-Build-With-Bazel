#include "internal/os_info.hpp"

#include <fmt/core.h>

int main()
{
#if defined(GREETING_BOSS)
    fmt::print("Hello, Boss!\n");
#endif
    fmt::print("The C++ standard is {}.\n", __cplusplus);
    fmt::print("\n");
    printSystemInfo();
    return 0;
}
