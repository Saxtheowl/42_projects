#pragma once

#include <vector>
#include <string>
#include "rigid_body.h"

struct StepMetrics
{
    int ground_contacts = 0;
    int sphere_collisions = 0;
    int wall_contacts = 0;
};

struct Scene
{
    Plane ground;
    Vector3 gravity;
    double ground_friction;
    double drag_coefficient;
    Vector3 wind;
    double bounds; // if >0, axis-aligned walls at +/-bounds on X/Z
    std::vector<RigidBody> bodies;

    Scene() : ground{Vector3(0, 1, 0), 0.0}, gravity(0, -9.81, 0), ground_friction(0.2), drag_coefficient(0.0), wind(0, 0, 0), bounds(-1.0) {}
    void step(double dt, StepMetrics *metrics = nullptr);
};

Scene build_catapult_scene(double speed, double angle_deg, int targets = 2, double spacing = 0.8);
Scene build_random_scene(double speed, double angle_deg, int target_count, unsigned int seed);
bool load_scene_from_file(const std::string &path, Scene &scene);
