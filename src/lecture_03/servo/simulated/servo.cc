#include "servo/servo.hpp"

#include <iostream>

class MockedServo final : public Servo
{
  public:
    MockedServo() = default;
    ~MockedServo() = default;

    void rotate(int angle) override
    {
        std::cout << "Mocked servo rotates to " << angle << " degrees.\n";
        angle_ = angle;
    }

    int getAngle() const override
    {
        return angle_;
    }

  private:
    int angle_;
};

std::unique_ptr<Servo> createServo()
{
    return std::make_unique<MockedServo>();
}
