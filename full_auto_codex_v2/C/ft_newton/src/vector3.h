#pragma once

#include <cmath>
#include <ostream>

struct Vector3
{
    double x;
    double y;
    double z;

    Vector3(double x = 0.0, double y = 0.0, double z = 0.0) : x(x), y(y), z(z) {}

    Vector3 operator+(const Vector3 &other) const { return Vector3(x + other.x, y + other.y, z + other.z); }
    Vector3 operator-(const Vector3 &other) const { return Vector3(x - other.x, y - other.y, z - other.z); }
    Vector3 operator*(double s) const { return Vector3(x * s, y * s, z * s); }
    Vector3 operator/(double s) const { return Vector3(x / s, y / s, z / s); }

    Vector3 &operator+=(const Vector3 &other)
    {
        x += other.x; y += other.y; z += other.z; return *this;
    }
    Vector3 &operator-=(const Vector3 &other)
    {
        x -= other.x; y -= other.y; z -= other.z; return *this;
    }
    Vector3 &operator*=(double s)
    {
        x *= s; y *= s; z *= s; return *this;
    }

    double dot(const Vector3 &other) const { return x * other.x + y * other.y + z * other.z; }
    double norm() const { return std::sqrt(dot(*this)); }
    Vector3 normalized() const
    {
        double n = norm();
        if (n == 0.0) return Vector3();
        return *this / n;
    }
};

inline std::ostream &operator<<(std::ostream &os, const Vector3 &v)
{
    os << "(" << v.x << "," << v.y << "," << v.z << ")";
    return os;
}
