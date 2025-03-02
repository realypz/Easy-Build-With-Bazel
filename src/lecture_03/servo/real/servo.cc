#include "servo/servo.hpp"

#include <iostream>

class DensoServo : public Servo
{
  public:
    DensoServo() = default;
    ~DensoServo() = default;

    void rotate(int angle) override
    {
        std::cout << "Real servo rotates to " << angle << " degrees.\n";
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
    return std::make_unique<DensoServo>();
}
