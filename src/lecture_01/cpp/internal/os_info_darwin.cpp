#include <iostream>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <sys/utsname.h>
#include <unistd.h>

void printSystemInfo()
{
    // Memory information
    int64_t totalPhysMem;
    size_t length = sizeof(totalPhysMem);
    sysctlbyname("hw.memsize", &totalPhysMem, &length, NULL, 0);

    // CPU information
    struct utsname cpuInfo;
    uname(&cpuInfo);

    int numCPU;
    length = sizeof(numCPU);
    sysctlbyname("hw.ncpu", &numCPU, &length, NULL, 0);

    std::cout << "Total Physical Memory: " << totalPhysMem / (1024 * 1024) << " MB" << std::endl;
    std::cout << "CPU Info: " << cpuInfo.machine << ", " << numCPU << " cores" << std::endl;
}
