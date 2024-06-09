#include "cpp/libfoo/foo.h"

#include <gtest/gtest.h>

TEST(FooTest, test1)
{
    EXPECT_EQ(100, returnOneHundred());
}
