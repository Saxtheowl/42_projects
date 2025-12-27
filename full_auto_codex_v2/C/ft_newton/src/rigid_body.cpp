#include "rigid_body.h"

void integrate(RigidBody &body, double dt)
{
    Vector3 acceleration = body.force / body.mass;
    body.velocity += acceleration * dt;
    body.position += body.velocity * dt;
}

bool resolve_sphere_plane(RigidBody &body, const Plane &plane, double friction)
{
    double dist = body.position.dot(plane.normal) + plane.offset - body.radius;
    if (dist < 0.0)
    {
        // push out of plane
        body.position -= plane.normal * dist;
        // reflect velocity along normal with restitution
        double vn = body.velocity.dot(plane.normal);
        if (vn < 0.0)
        {
            Vector3 v_norm = plane.normal * vn;
            Vector3 v_tan = body.velocity - v_norm;
            // simple Coulomb-like friction: damp tangent proportionally
            double damp = std::max(0.0, 1.0 - friction);
            body.velocity = v_tan * damp - v_norm * body.restitution;
        }
        return true;
    }
    return false;
}
