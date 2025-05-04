/*
cd src/lecture_04/cpp
bazelisk run //cpp:ex0

You should something like

Clang version: 20.1.3
Compiler Path: /opt/homebrew/opt/llvm/bin/clang
*/
#include <algorithm>
#include <iostream>
#include <vector>

int main()
{
    std::cout << "Compiler Path: " << COMPILER_PATH << std::endl;

#if defined(__clang__)
    std::cout << "Clang version: " << __clang_version__ << "\n";
#else
    std::cout << "Not built by Clang. Exit program...\n";
#endif
    return 0;
}
