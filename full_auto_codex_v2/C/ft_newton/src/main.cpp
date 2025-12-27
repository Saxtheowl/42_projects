#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <array>
#include "scene.h"

struct Options
{
    double speed = 12.0;
    double angle = 50.0;
    double dt = 0.02;
    double sim_time = 4.0;
    double friction = 0.2;
    bool friction_set = false;
    double drag = 0.0;
    Vector3 wind = Vector3(0, 0, 0);
    int targets = 2;
    double target_spacing = 0.8;
    double bounds = -1.0;
    double proj_mass = 1.0;
    double proj_restitution = 0.4;
    int random_targets = 0;
    unsigned int seed = 12345;
    bool seed_set = false;
    std::string csv_output;
    std::string json_output;
    std::string trace_output;
    std::string stats_output;
    std::string energy_csv_output;
    std::string stats_md_output;
    std::string config_path;
    std::string scene_path;
    bool show_help = false;
    bool auto_stop = false;
};

Options parse_args(int argc, char **argv)
{
    Options opt;
    for (int i = 1; i < argc; ++i)
    {
        std::string arg = argv[i];
        if (arg == "--speed" && i + 1 < argc) opt.speed = std::stod(argv[++i]);
        else if (arg == "--angle" && i + 1 < argc) opt.angle = std::stod(argv[++i]);
        else if (arg == "--dt" && i + 1 < argc) opt.dt = std::stod(argv[++i]);
        else if (arg == "--sim" && i + 1 < argc) opt.sim_time = std::stod(argv[++i]);
        else if (arg == "--csv" && i + 1 < argc) opt.csv_output = argv[++i];
        else if (arg == "--final-json" && i + 1 < argc) opt.json_output = argv[++i];
        else if (arg == "--trace-json" && i + 1 < argc) opt.trace_output = argv[++i];
        else if (arg == "--stats-json" && i + 1 < argc) opt.stats_output = argv[++i];
        else if (arg == "--stats-md" && i + 1 < argc) opt.stats_md_output = argv[++i];
        else if (arg == "--energy-csv" && i + 1 < argc) opt.energy_csv_output = argv[++i];
        else if (arg == "--friction" && i + 1 < argc) { opt.friction = std::stod(argv[++i]); opt.friction_set = true; }
        else if (arg == "--drag" && i + 1 < argc) opt.drag = std::stod(argv[++i]);
        else if (arg == "--mass" && i + 1 < argc) opt.proj_mass = std::stod(argv[++i]);
        else if (arg == "--restitution" && i + 1 < argc) opt.proj_restitution = std::stod(argv[++i]);
        else if (arg == "--targets" && i + 1 < argc) opt.targets = std::stoi(argv[++i]);
        else if (arg == "--target-spacing" && i + 1 < argc) opt.target_spacing = std::stod(argv[++i]);
        else if (arg == "--bounds" && i + 1 < argc) opt.bounds = std::stod(argv[++i]);
        else if (arg == "--random-targets" && i + 1 < argc) opt.random_targets = std::stoi(argv[++i]);
        else if (arg == "--seed" && i + 1 < argc) { opt.seed = static_cast<unsigned int>(std::stoul(argv[++i])); opt.seed_set = true; }
        else if (arg == "--wind" && i + 1 < argc)
        {
            std::string v = argv[++i];
            auto c1 = v.find(',');
            auto c2 = v.find(',', c1 == std::string::npos ? c1 : c1 + 1);
            if (c1 != std::string::npos && c2 != std::string::npos)
            {
                opt.wind.x = std::stod(v.substr(0, c1));
                opt.wind.y = std::stod(v.substr(c1 + 1, c2 - c1 - 1));
                opt.wind.z = std::stod(v.substr(c2 + 1));
            }
        }
        else if (arg == "--config" && i + 1 < argc) opt.config_path = argv[++i];
        else if (arg == "--scene" && i + 1 < argc) opt.scene_path = argv[++i];
        else if (arg == "--help") opt.show_help = true;
        else if (arg == "--auto-stop") opt.auto_stop = true;
    }
    return opt;
}

void load_config(const std::string &path, Options &opt)
{
    std::ifstream f(path.c_str());
    std::string line;
    while (std::getline(f, line))
    {
        if (line.empty() || line[0] == '#')
            continue;
        auto pos = line.find('=');
        if (pos == std::string::npos)
            continue;
        std::string key = line.substr(0, pos);
        std::string val = line.substr(pos + 1);
        if (key == "speed") opt.speed = std::stod(val);
        else if (key == "angle") opt.angle = std::stod(val);
        else if (key == "dt") opt.dt = std::stod(val);
        else if (key == "sim_time") opt.sim_time = std::stod(val);
        else if (key == "friction") { opt.friction = std::stod(val); opt.friction_set = true; }
        else if (key == "scene") opt.scene_path = val;
        else if (key == "trace_json") opt.trace_output = val;
        else if (key == "stats_json") opt.stats_output = val;
        else if (key == "stats_md") opt.stats_md_output = val;
        else if (key == "energy_csv") opt.energy_csv_output = val;
        else if (key == "drag") opt.drag = std::stod(val);
        else if (key == "targets") opt.targets = std::stoi(val);
        else if (key == "target_spacing") opt.target_spacing = std::stod(val);
        else if (key == "bounds") opt.bounds = std::stod(val);
        else if (key == "mass") opt.proj_mass = std::stod(val);
        else if (key == "restitution") opt.proj_restitution = std::stod(val);
        else if (key == "random_targets") opt.random_targets = std::stoi(val);
        else if (key == "seed") { opt.seed = static_cast<unsigned int>(std::stoul(val)); opt.seed_set = true; }
        else if (key == "wind")
        {
            auto c1 = val.find(',');
            auto c2 = val.find(',', c1 == std::string::npos ? c1 : c1 + 1);
            if (c1 != std::string::npos && c2 != std::string::npos)
            {
                opt.wind.x = std::stod(val.substr(0, c1));
                opt.wind.y = std::stod(val.substr(c1 + 1, c2 - c1 - 1));
                opt.wind.z = std::stod(val.substr(c2 + 1));
            }
        }
        else if (key == "auto_stop") opt.auto_stop = (val == "1" || val == "true" || val == "yes");
    }
}

void export_csv(const std::string &path, const std::vector<std::array<double, 7>> &rows)
{
    std::ofstream f(path.c_str());
    f << "time,x,y,z,vx,vy,vz\n";
    for (const auto &r : rows)
        f << r[0] << "," << r[1] << "," << r[2] << "," << r[3] << "," << r[4] << "," << r[5] << "," << r[6] << "\n";
}

void export_json(const std::string &path, const Scene &scene)
{
    std::ofstream f(path.c_str());
    f << "{\n  \"bodies\": [\n";
    for (size_t i = 0; i < scene.bodies.size(); ++i)
    {
        const RigidBody &b = scene.bodies[i];
        f << "    {\"id\": " << i << ", \"pos\": [" << b.position.x << "," << b.position.y << "," << b.position.z << "], "
          << "\"vel\": [" << b.velocity.x << "," << b.velocity.y << "," << b.velocity.z << "], "
          << "\"radius\": " << b.radius << "}";
        if (i + 1 < scene.bodies.size()) f << ",";
        f << "\n";
    }
    f << "  ]\n}\n";
}

void export_trace_json(const std::string &path, const std::vector<std::vector<RigidBody>> &frames, double dt)
{
    std::ofstream f(path.c_str());
    f << "{\n  \"dt\": " << dt << ",\n  \"frames\": [\n";
    for (size_t fi = 0; fi < frames.size(); ++fi)
    {
        f << "    {\"t\": " << (fi * dt) << ", \"bodies\": [";
        const auto &frame = frames[fi];
        for (size_t bi = 0; bi < frame.size(); ++bi)
        {
            const RigidBody &b = frame[bi];
            f << "{\"id\":" << bi << ",\"pos\":[" << b.position.x << "," << b.position.y << "," << b.position.z << "],"
              << "\"vel\":[" << b.velocity.x << "," << b.velocity.y << "," << b.velocity.z << "],"
              << "\"radius\":" << b.radius << "}";
            if (bi + 1 < frame.size()) f << ",";
        }
        f << "]}";
        if (fi + 1 < frames.size()) f << ",";
        f << "\n";
    }
    f << "  ]\n}\n";
}

static double total_energy(const Scene &scene)
{
    double g_mag = std::abs(scene.gravity.y);
    double total = 0.0;
    for (const auto &b : scene.bodies)
    {
        double kinetic = 0.5 * b.mass * b.velocity.norm() * b.velocity.norm();
        double potential = b.mass * g_mag * b.position.y;
        total += kinetic + potential;
    }
    return total;
}

void export_energy_csv(const std::string &path, const std::vector<std::pair<double, double>> &rows)
{
    std::ofstream f(path.c_str());
    f << "time,energy\n";
    for (auto &r : rows)
        f << r.first << "," << r.second << "\n";
}

void export_stats_json(const std::string &path, double max_height, double max_range, double total_energy_initial, double total_energy_final, int ground_contacts, int sphere_collisions, int wall_contacts, double simulated_time, int steps, double first_contact_time, double first_contact_range)
{
    std::ofstream f(path.c_str());
    f << "{\n"
      << "  \"max_height\": " << max_height << ",\n"
      << "  \"max_range\": " << max_range << ",\n"
      << "  \"total_energy_initial\": " << total_energy_initial << ",\n"
      << "  \"total_energy_final\": " << total_energy_final << ",\n"
      << "  \"ground_contacts\": " << ground_contacts << ",\n"
      << "  \"sphere_collisions\": " << sphere_collisions << ",\n"
      << "  \"wall_contacts\": " << wall_contacts << ",\n"
      << "  \"simulated_time\": " << simulated_time << ",\n"
      << "  \"steps\": " << steps << ",\n"
      << "  \"first_contact_time\": " << first_contact_time << ",\n"
      << "  \"first_contact_range\": " << first_contact_range << "\n"
      << "}\n";
}

void export_stats_md(const std::string &path, double max_height, double max_range, double total_energy_initial, double total_energy_final, int ground_contacts, int sphere_collisions, int wall_contacts, double simulated_time, int steps, double first_contact_time, double first_contact_range)
{
    std::ofstream f(path.c_str());
    f << "| metric | value |\n|---|---|\n";
    f << "| max_height | " << max_height << " |\n";
    f << "| max_range | " << max_range << " |\n";
    f << "| energy_initial | " << total_energy_initial << " |\n";
    f << "| energy_final | " << total_energy_final << " |\n";
    f << "| ground_contacts | " << ground_contacts << " |\n";
    f << "| sphere_collisions | " << sphere_collisions << " |\n";
    f << "| wall_contacts | " << wall_contacts << " |\n";
    f << "| simulated_time | " << simulated_time << " |\n";
    f << "| steps | " << steps << " |\n";
    f << "| first_contact_time | " << first_contact_time << " |\n";
    f << "| first_contact_range | " << first_contact_range << " |\n";
}

int main(int argc, char **argv)
{
    Options opt = parse_args(argc, argv);
    if (opt.show_help)
    {
        std::cout << "Usage: ft_newton [options]\n"
                     "  --speed <m/s>       Vitesse initiale (catapulte)\n"
                     "  --angle <deg>       Angle initial (catapulte)\n"
                     "  --dt <s>            Pas d'integration\n"
                     "  --sim <s>           Duree maximale de simulation\n"
                     "  --targets <n>       Nombre de cibles statiques\n"
                     "  --target-spacing <d>Espacement entre cibles\n"
                     "  --bounds <d>        Limite box (m) sur X/Z (|x|,|z| <= d)\n"
                     "  --random-targets <n>Nombre de cibles placées aléatoirement\n"
                     "  --seed <n>          Graine pour les cibles aléatoires\n"
                     "  --mass <kg>         Masse du projectile\n"
                     "  --restitution <r>   Restitution du projectile\n"
                     "  --friction <coeff>  Friction sol\n"
                     "  --drag <coeff>      Trainee quadratique (optionnelle)\n"
                     "  --wind x,y,z        Vent constant ajoute comme force par masse\n"
                     "  --scene <file>      Charger une scene texte (gravity/ground_friction/drag/body...)\n"
                     "  --config <file>     Charger une config (speed, angle, dt, sim_time, friction, drag, scene,...)\n"
                     "  --csv <file>        Export trajectoire principale en CSV\n"
                     "  --final-json <file> Export etat final en JSON\n"
                     "  --trace-json <file> Export trace JSON pour tous les corps\n"
                     "  --energy-csv <file> Export energie totale par pas\n"
                     "  --stats-json <file> Export stats (max_height, energie, contacts, temps)\n"
                     "  --stats-md <file>   Export stats en Markdown\n"
                     "  --auto-stop         Arret des pas quand tous les corps sont stables au sol\n"
                     "  --help              Affiche cette aide\n";
        return 0;
    }
    if (!opt.config_path.empty())
        load_config(opt.config_path, opt);
    Scene scene;
    if (!opt.scene_path.empty())
    {
        if (!load_scene_from_file(opt.scene_path, scene))
        {
            std::cerr << "Failed to load scene from " << opt.scene_path << "\n";
            return 1;
        }
    }
    else
    {
        if (opt.random_targets > 0)
            scene = build_random_scene(opt.speed, opt.angle, opt.random_targets, opt.seed);
        else
            scene = build_catapult_scene(opt.speed, opt.angle, opt.targets, opt.target_spacing);
        if (!scene.bodies.empty())
        {
            scene.bodies[0].mass = opt.proj_mass;
            scene.bodies[0].restitution = opt.proj_restitution;
        }
    }
    if (opt.friction_set || opt.scene_path.empty())
        scene.ground_friction = opt.friction;
    scene.drag_coefficient = opt.drag;
    scene.wind = opt.wind;
    scene.bounds = opt.bounds;
    int steps = static_cast<int>(opt.sim_time / opt.dt);
    std::cout << std::fixed << std::setprecision(3);
    std::cout << "# time(s) x y z vx vy vz\n";
    std::vector<std::array<double, 7>> rows;
    rows.reserve(steps);
    std::vector<std::pair<double, double>> energy_rows;
    if (!opt.energy_csv_output.empty())
        energy_rows.reserve(steps);
    std::vector<std::vector<RigidBody>> frames;
    if (!opt.trace_output.empty())
        frames.reserve(steps);
    double max_height = scene.bodies.empty() ? 0.0 : scene.bodies[0].position.y;
    double max_range = scene.bodies.empty() ? 0.0 : scene.bodies[0].position.x;
    int ground_contacts = 0;
    int sphere_collisions = 0;
    int wall_contacts = 0;
    bool above_ground = true;
    double initial_energy = total_energy(scene);
    int actual_steps = 0;
    std::vector<int> stable_counts(scene.bodies.size(), 0);
    double first_contact_time = -1.0;
    double first_contact_range = 0.0;
    double last_range = scene.bodies.empty() ? 0.0 : scene.bodies[0].position.x;
    for (int i = 0; i < steps; ++i)
    {
        double t = i * opt.dt;
        StepMetrics met;
        scene.step(opt.dt, &met);
        const RigidBody &proj = scene.bodies[0];
        rows.push_back({t, proj.position.x, proj.position.y, proj.position.z, proj.velocity.x, proj.velocity.y, proj.velocity.z});
        if (!opt.energy_csv_output.empty())
            energy_rows.push_back({t, total_energy(scene)});
        if (!opt.trace_output.empty())
            frames.push_back(scene.bodies);
        if (proj.position.y > max_height)
            max_height = proj.position.y;
        if (proj.position.x > max_range)
            max_range = proj.position.x;
        bool on_ground = proj.position.y <= (proj.radius + 1e-3);
        if (above_ground && on_ground)
            ground_contacts++;
        if (first_contact_time < 0.0 && on_ground)
        {
            first_contact_time = t;
            first_contact_range = proj.position.x;
        }
        last_range = proj.position.x;
        ground_contacts += met.ground_contacts;
        sphere_collisions += met.sphere_collisions;
        wall_contacts += met.wall_contacts;
        above_ground = !on_ground;

        bool all_stable = true;
        for (size_t bi = 0; bi < scene.bodies.size(); ++bi)
        {
            const RigidBody &b = scene.bodies[bi];
            bool grounded = b.position.y <= (b.radius + 1e-3);
            double speed = b.velocity.norm();
            if (grounded && speed < 5e-3)
                stable_counts[bi]++;
            else
                stable_counts[bi] = 0;
            if (stable_counts[bi] < 3)
                all_stable = false;
        }
        actual_steps = i + 1;
        std::cout << t << " "
                  << proj.position.x << " " << proj.position.y << " " << proj.position.z << " "
                  << proj.velocity.x << " " << proj.velocity.y << " " << proj.velocity.z << "\n";
        if (opt.auto_stop && (all_stable || total_energy(scene) < 1e-4))
            break;
    }
    if (!opt.csv_output.empty())
        export_csv(opt.csv_output, rows);
    if (!opt.json_output.empty())
        export_json(opt.json_output, scene);
    if (!opt.trace_output.empty())
        export_trace_json(opt.trace_output, frames, opt.dt);
    if (!opt.energy_csv_output.empty())
        export_energy_csv(opt.energy_csv_output, energy_rows);
    if (!opt.stats_output.empty())
    {
        double final_energy = total_energy(scene);
        if (first_contact_time < 0.0)
        {
            first_contact_time = actual_steps * opt.dt;
            first_contact_range = last_range;
        }
        export_stats_json(opt.stats_output, max_height, max_range, initial_energy, final_energy, ground_contacts, sphere_collisions, wall_contacts, actual_steps * opt.dt, actual_steps, first_contact_time, first_contact_range);
    }
    if (!opt.stats_md_output.empty())
    {
        double final_energy = total_energy(scene);
        if (first_contact_time < 0.0)
        {
            first_contact_time = actual_steps * opt.dt;
            first_contact_range = last_range;
        }
        export_stats_md(opt.stats_md_output, max_height, max_range, initial_energy, final_energy, ground_contacts, sphere_collisions, wall_contacts, actual_steps * opt.dt, actual_steps, first_contact_time, first_contact_range);
    }
    return 0;
}
