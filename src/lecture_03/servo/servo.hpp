#pragma once

#include <memory>

class Servo
{
  public:
    virtual ~Servo() = default;
    virtual void rotate(int angle) = 0;
    virtual int getAngle() const = 0;
};

std::unique_ptr<Servo> createServo();
