#pragma once

#include "vector3.h"

struct RigidBody
{
    double mass;
    double restitution;
    double radius;
    Vector3 position;
    Vector3 velocity;
    Vector3 force;

    RigidBody(double m = 1.0, double rest = 0.5, double r = 0.5)
        : mass(m), restitution(rest), radius(r), position(), velocity(), force() {}

    void apply_force(const Vector3 &f) { force += f; }
    void clear_forces() { force = Vector3(); }
};

struct Plane
{
    Vector3 normal;
    double offset; // plane equation: normal dot p + offset = 0
};

void integrate(RigidBody &body, double dt);
bool resolve_sphere_plane(RigidBody &body, const Plane &plane, double friction);
