#include <ncurses.h>
#include <chrono>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <string>
#include <algorithm>
#include <random>
#include <thread>
#include <fstream>

enum class EntityType { Player, Enemy, Boss, PlayerBullet, EnemyBullet, Powerup };

enum class PowerType { Life, Shield, Rapid };

struct Entity
{
    int x;
    int y;
    int vx;
    int vy;
    EntityType type;
    bool alive;
    double next_action_ms = 0.0;
    int hp = 1;
    PowerType power = PowerType::Life;
};

struct GameState
{
    int width;
    int height;
    Entity player;
    std::vector<Entity> entities;
    std::vector<std::pair<int, int>> stars;
    int lives = 3;
    int max_lives = 5;
    int score = 0;
    int high_score = 0;
    std::vector<int> high_scores;
    int total_waves = 15;
    bool victory = false;
    bool running = true;
    bool paused = false;
    std::mt19937 rng;
    double last_shot_ms = 0.0;
    double last_enemy_spawn_ms = 0.0;
    int wave = 1;
    double next_wave_ms = 0.0;
    double invuln_until_ms = 0.0;
    double shield_until_ms = 0.0;
    double rapid_until_ms = 0.0;
};

static double now_ms()
{
    using namespace std::chrono;
    return duration_cast<milliseconds>(steady_clock::now().time_since_epoch()).count();
}

static void init_ncurses()
{
    initscr();
    noecho();
    curs_set(0);
    keypad(stdscr, TRUE);
    nodelay(stdscr, TRUE);
    timeout(0);
}

static void shutdown_ncurses()
{
    nodelay(stdscr, FALSE);
    echo();
    curs_set(1);
    endwin();
}

static void load_high_scores(GameState &g)
{
    g.high_scores.clear();
    std::ifstream f("highscore.txt");
    int v;
    while (f && f >> v)
        g.high_scores.push_back(v);
    if (g.high_scores.empty())
        g.high_scores.push_back(0);
    std::sort(g.high_scores.begin(), g.high_scores.end(), std::greater<int>());
    g.high_score = g.high_scores.front();
}

static void save_high_scores(GameState &g)
{
    std::sort(g.high_scores.begin(), g.high_scores.end(), std::greater<int>());
    if (g.high_scores.size() > 5)
        g.high_scores.resize(5);
    std::ofstream f("highscore.txt");
    for (size_t i = 0; i < g.high_scores.size(); ++i)
        f << g.high_scores[i] << (i + 1 < g.high_scores.size() ? "\n" : "");
}

static void add_star_row(GameState &g)
{
    std::uniform_int_distribution<int> dist(0, 100);
    for (int x = 1; x < g.width - 1; ++x)
    {
        if (dist(g.rng) < 5) // 5% chance
            g.stars.push_back({x, 0});
    }
}

static void scroll_background(GameState &g)
{
    for (auto &s : g.stars)
        s.second += 1;
    g.stars.erase(std::remove_if(g.stars.begin(), g.stars.end(),
                                 [&](const std::pair<int, int> &s)
                                 { return s.second >= g.height - 2; }),
                  g.stars.end());
    add_star_row(g);
}

static void spawn_enemy(GameState &g, int y_offset = 1)
{
    std::uniform_int_distribution<int> dist_x(1, g.width - 2);
    Entity e;
    e.x = dist_x(g.rng);
    e.y = y_offset;
    e.vx = 0;
    e.vy = 1;
    e.type = EntityType::Enemy;
    e.alive = true;
    e.next_action_ms = now_ms() + 2000.0;
    e.hp = 1;
    g.entities.push_back(e);
}

static void enemy_fire(GameState &g, Entity &enemy)
{
    Entity b{enemy.x, enemy.y + 1, 0, 1, EntityType::EnemyBullet, true, 0.0};
    b.hp = 1;
    g.entities.push_back(b);
}

static void spawn_powerup(GameState &g, int x, int y)
{
    Entity p{x, y, 0, 1, EntityType::Powerup, true, 0.0};
    p.hp = 1;
    std::uniform_int_distribution<int> which(0, 99);
    int r = which(g.rng);
    if (r < 50)
        p.power = PowerType::Life;
    else if (r < 75)
        p.power = PowerType::Shield;
    else
        p.power = PowerType::Rapid;
    g.entities.push_back(p);
}

static void spawn_boss(GameState &g)
{
    Entity b;
    b.x = g.width / 2;
    b.y = 2;
    b.vx = 1;
    b.vy = 0;
    b.type = EntityType::Boss;
    b.alive = true;
    b.hp = 15 + (g.wave * 2);
    b.next_action_ms = now_ms() + 1000.0;
    g.entities.push_back(b);
}

static void fire_player(GameState &g)
{
    double t = now_ms();
    double cadence = (t < g.rapid_until_ms) ? 80.0 : 200.0;
    if (t - g.last_shot_ms < cadence)
        return;
    g.last_shot_ms = t;
    Entity b{g.player.x, g.player.y - 1, 0, -1, EntityType::PlayerBullet, true, 0.0};
    b.hp = 1;
    g.entities.push_back(b);
}

static void handle_input(GameState &g)
{
    int ch = getch();
    switch (ch)
    {
    case 'q':
        g.running = false;
        break;
    case 'p':
        g.paused = !g.paused;
        break;
    case ' ':
        fire_player(g);
        break;
    case KEY_LEFT:
    case 'a':
        if (g.player.x > 1)
            g.player.x -= 1;
        break;
    case KEY_RIGHT:
    case 'd':
        if (g.player.x < g.width - 2)
            g.player.x += 1;
        break;
    case KEY_UP:
    case 'w':
        if (g.player.y > 1)
            g.player.y -= 1;
        break;
    case KEY_DOWN:
    case 's':
        if (g.player.y < g.height - 2)
            g.player.y += 1;
        break;
    default:
        break;
    }
}

static void update_entities(GameState &g)
{
    std::uniform_real_distribution<double> chance(0.0, 1.0);
    double t = now_ms();
    // spawn batches by wave
    bool boss_alive = std::any_of(g.entities.begin(), g.entities.end(), [](const Entity &e){ return e.alive && e.type == EntityType::Boss; });
    if (!boss_alive && t > g.next_wave_ms && g.wave <= g.total_waves)
    {
        int enemies_to_spawn = 3 + g.wave;
        if (g.wave % 5 == 0)
            spawn_boss(g);
        else
        {
            for (int i = 0; i < enemies_to_spawn; ++i)
                spawn_enemy(g, 1 - i); // staggered vertically
        }
        g.wave++;
        g.next_wave_ms = t + 6000.0 * std::max(1, 4 - g.wave / 5); // faster pacing later
    }
    for (auto &e : g.entities)
    {
        if (!e.alive)
            continue;
        if (e.type == EntityType::Enemy)
        {
            e.x += e.vx;
            e.y += e.vy;
            if (e.x <= 1 || e.x >= g.width - 2)
                e.vx = -e.vx;
            if (t > e.next_action_ms)
            {
                enemy_fire(g, e);
                e.next_action_ms = t + std::max(500.0, 1500.0 - (g.wave * 50.0));
            }
        }
        else if (e.type == EntityType::Boss)
        {
            e.x += e.vx;
            if (e.x <= 2 || e.x >= g.width - 3)
                e.vx = -e.vx;
            if (t > e.next_action_ms)
            {
                // triple shot
                Entity b1{e.x, e.y + 1, -1, 1, EntityType::EnemyBullet, true, 0.0, 1};
                Entity b2{e.x, e.y + 1, 0, 1, EntityType::EnemyBullet, true, 0.0, 1};
                Entity b3{e.x, e.y + 1, 1, 1, EntityType::EnemyBullet, true, 0.0, 1};
                g.entities.push_back(b1);
                g.entities.push_back(b2);
                g.entities.push_back(b3);
                e.next_action_ms = t + std::max(400.0, 900.0 - (g.wave * 30.0));
            }
        }
        else if (e.type == EntityType::PlayerBullet)
            e.y += e.vy;
        else if (e.type == EntityType::EnemyBullet)
        {
            e.y += e.vy;
            e.x += e.vx;
        }
        else if (e.type == EntityType::Powerup)
            e.y += e.vy;
        if (e.y <= 0 || e.y >= g.height - 1)
            e.alive = false;
        if (e.x <= 0 || e.x >= g.width - 1)
            e.alive = false;
    }
}

static void handle_collisions(GameState &g)
{
    double t = now_ms();
    for (auto &bullet : g.entities)
    {
        if (!bullet.alive || bullet.type != EntityType::PlayerBullet)
            continue;
        for (auto &enemy : g.entities)
        {
            if (!enemy.alive || (enemy.type != EntityType::Enemy && enemy.type != EntityType::Boss))
                continue;
            if (bullet.x == enemy.x && bullet.y == enemy.y)
            {
                bullet.alive = false;
                enemy.hp -= 1;
                if (enemy.hp <= 0)
                {
                    enemy.alive = false;
                    g.score += (enemy.type == EntityType::Boss) ? 300 : 10;
                    std::uniform_int_distribution<int> drop(0, 99);
                    if (drop(g.rng) < 12 || enemy.type == EntityType::Boss) // boss guarantees at least one
                        spawn_powerup(g, enemy.x, enemy.y);
                }
                break;
            }
        }
    }
    for (auto &e : g.entities)
    {
        if (!e.alive)
            continue;
        if (e.type == EntityType::Powerup && e.x == g.player.x && e.y == g.player.y)
        {
            e.alive = false;
            if (g.lives < g.max_lives)
                g.lives += 1;
            g.score += 50;
            continue;
        }
        if ((e.type == EntityType::Enemy || e.type == EntityType::EnemyBullet) &&
            e.x == g.player.x && e.y == g.player.y && t > g.invuln_until_ms && t > g.shield_until_ms)
        {
            e.alive = false;
            g.lives -= 1;
            g.invuln_until_ms = t + 1500.0; // 1.5s invuln
            g.player.x = g.width / 2;
            g.player.y = g.height - 3;
            if (g.lives <= 0)
                g.running = false;
        }
        if (e.type == EntityType::Powerup && e.x == g.player.x && e.y == g.player.y)
        {
            e.alive = false;
            if (e.power == PowerType::Life && g.lives < g.max_lives)
            {
                g.lives += 1;
                g.score += 50;
            }
            else if (e.power == PowerType::Shield)
            {
                g.shield_until_ms = t + 5000.0;
                g.invuln_until_ms = t + 5000.0;
            }
            else if (e.power == PowerType::Rapid)
            {
                g.rapid_until_ms = t + 6000.0;
            }
        }
    }
}

static void cleanup_entities(GameState &g)
{
    g.entities.erase(std::remove_if(g.entities.begin(), g.entities.end(),
                                    [](const Entity &e)
                                    { return !e.alive; }),
                     g.entities.end());
}

static void render(const GameState &g)
{
    erase();
    // borders
    for (int x = 0; x < g.width; ++x)
    {
        mvaddch(0, x, '-');
        mvaddch(g.height - 1, x, '-');
    }
    for (int y = 0; y < g.height; ++y)
    {
        mvaddch(y, 0, '|');
        mvaddch(y, g.width - 1, '|');
    }
    // stars
    for (const auto &s : g.stars)
        mvaddch(s.second, s.first, '.');
    // entities
    mvaddch(g.player.y, g.player.x, (g.shield_until_ms > now_ms()) ? 'U' : 'A');
    for (const auto &e : g.entities)
    {
        if (!e.alive)
            continue;
        char c = '?';
        if (e.type == EntityType::Enemy)
            c = 'M';
        else if (e.type == EntityType::PlayerBullet)
            c = '|';
        else if (e.type == EntityType::EnemyBullet)
            c = 'v';
        else if (e.type == EntityType::Powerup)
            c = '+';
        mvaddch(e.y, e.x, c);
    }
    mvprintw(g.height, 0, "Score:%d High:%d Lives:%d/%d Wave:%d/%d  (space: shoot, arrows/WASD move, p pause, q quit)", g.score, g.high_score, g.lives, g.max_lives, g.wave, g.total_waves);
    int hud_line = g.height + 1;
    mvprintw(hud_line++, 0, "Top: ");
    for (size_t i = 0; i < g.high_scores.size() && i < 3; ++i)
        mvprintw(hud_line - 1, 5 + (int)i * 8, "%zu:%d", i + 1, g.high_scores[i]);
    for (const auto &e : g.entities)
    {
        if (e.alive && e.type == EntityType::Boss)
        {
            mvprintw(hud_line++, 0, "Boss HP: %d", e.hp);
            break;
        }
    }
    if (g.shield_until_ms > now_ms())
        mvprintw(hud_line++, 0, "Shield active (%.1fs)", (g.shield_until_ms - now_ms()) / 1000.0);
    if (g.rapid_until_ms > now_ms())
        mvprintw(hud_line++, 0, "Rapid fire (%.1fs)", (g.rapid_until_ms - now_ms()) / 1000.0);
    refresh();
}

int main()
{
    GameState g;
    int rows, cols;
    init_ncurses();
    getmaxyx(stdscr, rows, cols);
    g.width = std::min(60, cols - 2);
    g.height = std::min(22, rows - 3);
    if (g.width < 20 || g.height < 12)
    {
        shutdown_ncurses();
        fprintf(stderr, "Terminal too small (need at least 20x12 usable). Resize and retry.\n");
        return 1;
    }
    g.player.x = g.width / 2;
    g.player.y = g.height - 3;
    g.player.vx = 0;
    g.player.vy = 0;
    g.player.type = EntityType::Player;
    g.player.alive = true;
    load_high_scores(g);
    g.rng.seed(std::random_device{}());
    auto last_frame = std::chrono::steady_clock::now();
    while (g.running)
    {
        handle_input(g);
        if (!g.paused)
        {
            scroll_background(g);
            update_entities(g);
            handle_collisions(g);
            cleanup_entities(g);
            bool enemies_left = std::any_of(g.entities.begin(), g.entities.end(), [](const Entity &e)
            { return e.alive && (e.type == EntityType::Enemy || e.type == EntityType::Boss || e.type == EntityType::EnemyBullet || e.type == EntityType::Powerup); });
            if (!enemies_left && g.wave > g.total_waves)
            {
                g.victory = true;
                g.running = false;
            }
        }
        render(g);
        auto now = std::chrono::steady_clock::now();
        std::chrono::duration<double, std::milli> frame_time = now - last_frame;
        last_frame = now;
        double sleep_ms = 16.0 - frame_time.count();
        if (sleep_ms > 0)
            std::this_thread::sleep_for(std::chrono::milliseconds((int)sleep_ms));
    }
    shutdown_ncurses();
    g.high_scores.push_back(g.score);
    std::sort(g.high_scores.begin(), g.high_scores.end(), std::greater<int>());
    if (g.high_scores.size() > 5)
        g.high_scores.resize(5);
    g.high_score = g.high_scores.front();
    save_high_scores(g);
    if (g.victory)
        g.score += 200; // victory bonus
    printf("%s Final score: %d\nTop scores:\n", g.victory ? "Victory!" : "Game over!", g.score);
    for (size_t i = 0; i < g.high_scores.size(); ++i)
        printf("%zu) %d\n", i + 1, g.high_scores[i]);
    return 0;
}
