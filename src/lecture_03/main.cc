#include "foo/foo.hpp"
#include "servo/servo.hpp"

int main()
{
    foo();

    auto servo = createServo();
    servo->rotate(90);

    return 0;
}
