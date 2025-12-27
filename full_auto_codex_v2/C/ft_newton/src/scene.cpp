#include "scene.h"
#include <cmath>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <cctype>
#include <random>

void Scene::step(double dt, StepMetrics *metrics)
{
    // apply forces and integrate
    for (auto &b : bodies)
    {
        b.clear_forces();
        b.apply_force(gravity * b.mass);
        if (wind.norm() > 0.0)
            b.apply_force(wind * b.mass);
        if (drag_coefficient > 0.0)
        {
            double speed = b.velocity.norm();
            Vector3 drag = b.velocity * (-drag_coefficient * speed);
            b.apply_force(drag);
        }
        integrate(b, dt);
        if (resolve_sphere_plane(b, ground, ground_friction) && metrics)
            metrics->ground_contacts++;
        if (bounds > 0.0)
        {
            Plane left{Vector3(1, 0, 0), bounds};
            Plane right{Vector3(-1, 0, 0), bounds};
            Plane back{Vector3(0, 0, 1), bounds};
            Plane front{Vector3(0, 0, -1), bounds};
            if (resolve_sphere_plane(b, left, ground_friction) && metrics) metrics->wall_contacts++;
            if (resolve_sphere_plane(b, right, ground_friction) && metrics) metrics->wall_contacts++;
            if (resolve_sphere_plane(b, back, ground_friction) && metrics) metrics->wall_contacts++;
            if (resolve_sphere_plane(b, front, ground_friction) && metrics) metrics->wall_contacts++;
        }
    }

    // pairwise sphere collisions (naive O(n^2))
    for (size_t i = 0; i < bodies.size(); ++i)
    {
        for (size_t j = i + 1; j < bodies.size(); ++j)
        {
            RigidBody &a = bodies[i];
            RigidBody &b = bodies[j];
            Vector3 delta = b.position - a.position;
            double dist = delta.norm();
            double minDist = a.radius + b.radius;
            if (dist == 0.0)
                delta = Vector3(1, 0, 0), dist = 1e-6; // avoid division by zero
            if (dist < minDist)
            {
                Vector3 n = delta / dist;
                double penetration = minDist - dist;
                // positional correction proportionnel aux masses
                double invMassA = 1.0 / a.mass;
                double invMassB = 1.0 / b.mass;
                double invSum = invMassA + invMassB;
                a.position -= n * (penetration * (invMassA / invSum));
                b.position += n * (penetration * (invMassB / invSum));

                // relative velocity
                Vector3 rv = b.velocity - a.velocity;
                double velAlongNormal = rv.dot(n);
                if (metrics)
                    metrics->sphere_collisions++;
                if (velAlongNormal < 0.0)
                {
                    double e = std::min(a.restitution, b.restitution);
                    double jImpulse = -(1 + e) * velAlongNormal;
                    jImpulse /= invSum;
                    Vector3 impulse = n * jImpulse;
                    a.velocity -= impulse * invMassA;
                    b.velocity += impulse * invMassB;
                    if (metrics)
                        metrics->sphere_collisions++;
                }
            }
        }
    }
}

Scene build_catapult_scene(double speed, double angle_deg, int targets, double spacing)
{
    Scene scene;
    double rad = angle_deg * M_PI / 180.0;
    RigidBody projectile(1.0, 0.6, 0.4);
    projectile.position = Vector3(0.0, projectile.radius + 0.1, 0.0);
    projectile.velocity = Vector3(speed * std::cos(rad), speed * std::sin(rad), 0.0);
    scene.bodies.push_back(projectile);

    double base_x = 5.0;
    for (int i = 0; i < targets; ++i)
    {
        RigidBody t(5.0, 0.3, 0.5);
        t.position = Vector3(base_x + i * spacing, t.radius, 0.0);
        scene.bodies.push_back(t);
    }

    return scene;
}

Scene build_random_scene(double speed, double angle_deg, int target_count, unsigned int seed)
{
    Scene scene;
    double rad = angle_deg * M_PI / 180.0;
    RigidBody projectile(1.0, 0.6, 0.4);
    projectile.position = Vector3(0.0, projectile.radius + 0.1, 0.0);
    projectile.velocity = Vector3(speed * std::cos(rad), speed * std::sin(rad), 0.0);
    scene.bodies.push_back(projectile);

    std::mt19937 rng(seed);
    std::uniform_real_distribution<double> dist_x(4.0, 9.0);
    std::uniform_real_distribution<double> dist_y(0.3, 1.0);
    for (int i = 0; i < target_count; ++i)
    {
        RigidBody t(5.0, 0.3, 0.5);
        t.position = Vector3(dist_x(rng), t.radius + dist_y(rng), 0.0);
        scene.bodies.push_back(t);
    }
    return scene;
}

static void trim(std::string &s)
{
    auto not_space = [](int ch) { return !std::isspace(ch); };
    s.erase(s.begin(), std::find_if(s.begin(), s.end(), not_space));
    s.erase(std::find_if(s.rbegin(), s.rend(), not_space).base(), s.end());
}

static bool parse_vec3(const std::string &value, Vector3 &out)
{
    std::stringstream ss(value);
    std::string tok;
    double vals[3];
    for (int i = 0; i < 3; ++i)
    {
        if (!std::getline(ss, tok, ','))
            return false;
        trim(tok);
        vals[i] = std::stod(tok);
    }
    if (std::getline(ss, tok, ','))
        return false;
    out = Vector3(vals[0], vals[1], vals[2]);
    return true;
}

bool load_scene_from_file(const std::string &path, Scene &scene)
{
    std::ifstream f(path.c_str());
    if (!f.is_open())
        return false;

    scene = Scene(); // reset defaults
    std::string line;
    size_t line_no = 0;
    while (std::getline(f, line))
    {
        ++line_no;
        trim(line);
        if (line.empty() || line[0] == '#')
            continue;
        auto pos = line.find('=');
        if (pos == std::string::npos)
            continue;
        std::string key = line.substr(0, pos);
        std::string val = line.substr(pos + 1);
        trim(key);
        trim(val);

        try
        {
            if (key == "gravity")
            {
                Vector3 g;
                if (!parse_vec3(val, g))
                    return false;
                scene.gravity = g;
            }
            else if (key == "ground_friction")
            {
                scene.ground_friction = std::stod(val);
            }
            else if (key == "drag")
            {
                scene.drag_coefficient = std::stod(val);
            }
            else if (key == "wind")
            {
                Vector3 w;
                if (!parse_vec3(val, w))
                    return false;
                scene.wind = w;
            }
            else if (key == "bounds")
            {
                scene.bounds = std::stod(val);
            }
            else if (key == "body")
            {
                std::stringstream ss(val);
                std::string tok;
                double parts[9];
                int idx = 0;
                while (std::getline(ss, tok, ','))
                {
                    trim(tok);
                    if (tok.empty())
                        continue;
                    if (idx >= 9)
                        return false;
                    parts[idx++] = std::stod(tok);
                }
                if (idx != 9)
                    return false;
                RigidBody b(parts[0], parts[1], parts[2]);
                b.position = Vector3(parts[3], parts[4], parts[5]);
                b.velocity = Vector3(parts[6], parts[7], parts[8]);
                scene.bodies.push_back(b);
            }
        }
        catch (const std::exception &)
        {
            return false;
        }
    }
    return !scene.bodies.empty();
}
