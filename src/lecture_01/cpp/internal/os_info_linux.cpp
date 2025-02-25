#include <iostream>
#include <sys/sysinfo.h>
#include <sys/utsname.h>

void printSystemInfo()
{
    // Memory information
    struct sysinfo memInfo;
    sysinfo(&memInfo);
    long long totalPhysMem = memInfo.totalram;
    totalPhysMem *= memInfo.mem_unit;

    // CPU information
    struct utsname cpuInfo;
    uname(&cpuInfo);

    std::cout << "Total Physical Memory: " << totalPhysMem / (1024 * 1024) << " MB" << std::endl;
    std::cout << "CPU Info: " << cpuInfo.machine << std::endl;
}
