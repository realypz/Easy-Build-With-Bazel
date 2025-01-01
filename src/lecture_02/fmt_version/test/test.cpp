#include "fmt_version.hpp"

#include <gtest/gtest.h>
#include <iostream>

TEST(FmtVersionTest, TestPrintFmtVersion)
{
    std::cout << "In @fmt_version//cpp:fmt_version_test:\n";
    printFmtVersion();
    ASSERT_TRUE(true);
}
