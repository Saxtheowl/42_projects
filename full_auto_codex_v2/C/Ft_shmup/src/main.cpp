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

enum class EntityType { Player, Enemy, Kamikaze, Sniper, Boss, PlayerBullet, EnemyBullet, Powerup };

enum class PowerType { Life, Shield, Rapid, Spread, Slow, Bomb };

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
    int max_hp = 1;
    PowerType power = PowerType::Life;
    bool enraged = false;
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
    int bombs = 1;
    int max_bombs = 3;
    int score = 0;
    int high_score = 0;
    std::vector<int> high_scores;
    int total_waves = 15;
    bool victory = false;
    bool running = true;
    bool paused = false;
    bool show_help = false;
    bool post_game = false;
    bool restart_requested = false;
    bool in_title = false;
    bool infinite_mode = false;
    double banner_until_ms = 0.0;
    std::string banner_text;
    int combo_count = 0;
    double combo_until_ms = 0.0;
    bool quit_prompt = false;
    double game_time_ms = 0.0;
    double last_real_ms = 0.0;
    int last_move_dx = 0;
    int last_move_dy = -1;
    double dash_until_ms = 0.0;
    double dash_cd_until_ms = 0.0;
    bool auto_fire = false;
    std::mt19937 rng;
    double last_shot_ms = 0.0;
    double last_enemy_spawn_ms = 0.0;
    int wave = 1;
    double next_wave_ms = 0.0;
    double invuln_until_ms = 0.0;
    double shield_until_ms = 0.0;
    double rapid_until_ms = 0.0;
    double spread_until_ms = 0.0;
    double slow_until_ms = 0.0;
};

static double now_ms()
{
    using namespace std::chrono;
    return duration_cast<milliseconds>(steady_clock::now().time_since_epoch()).count();
}

static double game_now(const GameState &g)
{
    return g.game_time_ms;
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

static void set_banner(GameState &g, const std::string &text, double duration_ms);
static void init_game(GameState &g, int width, int height);
static void go_to_title(GameState &g);

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
    e.next_action_ms = game_now(g) + 2000.0;
    e.hp = 1;
    e.max_hp = e.hp;
    g.entities.push_back(e);
}

static void spawn_kamikaze(GameState &g, int y_offset = 1)
{
    std::uniform_int_distribution<int> dist_x(1, g.width - 2);
    Entity e;
    e.x = dist_x(g.rng);
    e.y = y_offset;
    e.vx = 0;
    e.vy = 1;
    e.type = EntityType::Kamikaze;
    e.alive = true;
    e.next_action_ms = 0.0;
    e.hp = 1;
    e.max_hp = e.hp;
    g.entities.push_back(e);
}

static void spawn_sniper(GameState &g, int y_offset = 1)
{
    std::uniform_int_distribution<int> dist_x(1, g.width - 2);
    Entity e;
    e.x = dist_x(g.rng);
    e.y = y_offset;
    e.vx = 0;
    e.vy = 1;
    e.type = EntityType::Sniper;
    e.alive = true;
    e.next_action_ms = game_now(g) + 1200.0;
    e.hp = 2;
    e.max_hp = e.hp;
    g.entities.push_back(e);
}

static void enemy_fire(GameState &g, Entity &enemy)
{
    Entity b{enemy.x, enemy.y + 1, 0, 1, EntityType::EnemyBullet, true, 0.0};
    b.hp = 1;
    b.max_hp = b.hp;
    g.entities.push_back(b);
}

static void spawn_powerup(GameState &g, int x, int y)
{
    Entity p{x, y, 0, 1, EntityType::Powerup, true, 0.0};
    p.hp = 1;
    p.max_hp = p.hp;
    std::uniform_int_distribution<int> which(0, 99);
    int r = which(g.rng);
    if (r < 25)
        p.power = PowerType::Life;
    else if (r < 45)
        p.power = PowerType::Shield;
    else if (r < 65)
        p.power = PowerType::Rapid;
    else if (r < 80)
        p.power = PowerType::Spread;
    else if (r < 92)
        p.power = PowerType::Slow;
    else
        p.power = PowerType::Bomb;
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
    b.max_hp = b.hp;
    b.enraged = false;
    b.next_action_ms = game_now(g) + 1000.0;
    g.entities.push_back(b);
}

static void fire_player(GameState &g)
{
    double t = game_now(g);
    double cadence = (t < g.rapid_until_ms) ? 80.0 : 200.0;
    if (t - g.last_shot_ms < cadence)
        return;
    g.last_shot_ms = t;
    if (t < g.spread_until_ms)
    {
        Entity b1{g.player.x - 1, g.player.y - 1, -1, -1, EntityType::PlayerBullet, true, 0.0};
        Entity b2{g.player.x, g.player.y - 1, 0, -1, EntityType::PlayerBullet, true, 0.0};
        Entity b3{g.player.x + 1, g.player.y - 1, 1, -1, EntityType::PlayerBullet, true, 0.0};
        b1.hp = b2.hp = b3.hp = 1;
        b1.max_hp = b2.max_hp = b3.max_hp = 1;
        g.entities.push_back(b1);
        g.entities.push_back(b2);
        g.entities.push_back(b3);
    }
    else
    {
        Entity b{g.player.x, g.player.y - 1, 0, -1, EntityType::PlayerBullet, true, 0.0};
        b.hp = 1;
        b.max_hp = b.hp;
        g.entities.push_back(b);
    }
}

static void dash_player(GameState &g)
{
    if (g.post_game)
        return;
    double t = game_now(g);
    if (t < g.dash_cd_until_ms)
        return;
    int dx = g.last_move_dx;
    int dy = g.last_move_dy;
    if (dx == 0 && dy == 0)
        dy = -1;
    int steps = 3;
    int nx = g.player.x + dx * steps;
    int ny = g.player.y + dy * steps;
    nx = std::max(1, std::min(g.width - 2, nx));
    ny = std::max(1, std::min(g.height - 2, ny));
    g.player.x = nx;
    g.player.y = ny;
    g.dash_until_ms = t + 300.0;
    g.dash_cd_until_ms = t + 2000.0;
    if (g.invuln_until_ms < g.dash_until_ms)
        g.invuln_until_ms = g.dash_until_ms;
}

static void apply_bomb(GameState &g)
{
    if (g.bombs <= 0)
        return;
    g.bombs -= 1;
    g.combo_count = 0;
    g.combo_until_ms = 0.0;
    int kills = 0;
    for (auto &e : g.entities)
    {
        if (!e.alive)
            continue;
        if (e.type == EntityType::EnemyBullet)
        {
            e.alive = false;
            continue;
        }
        if (e.type == EntityType::Enemy || e.type == EntityType::Kamikaze || e.type == EntityType::Sniper)
        {
            e.alive = false;
            kills++;
            if (e.type == EntityType::Sniper)
                g.score += 25;
            else if (e.type == EntityType::Kamikaze)
                g.score += 15;
            else
                g.score += 10;
            continue;
        }
        if (e.type == EntityType::Boss)
        {
            e.hp -= 3;
            if (e.hp <= 0)
            {
                e.alive = false;
                g.score += 300;
                kills++;
            }
        }
    }
    set_banner(g, kills > 0 ? "Bomb!" : "Bomb used", 1200.0);
}

static void handle_input(GameState &g)
{
    int ch = getch();
    if (g.in_title)
    {
        if (ch == 'q')
            g.running = false;
        else if (ch == 'm')
            g.infinite_mode = !g.infinite_mode;
        else if (ch == ' ' || ch == '\n')
        {
            init_game(g, g.width, g.height);
            g.in_title = false;
        }
        return;
    }
    switch (ch)
    {
    case 'x':
        if (!g.post_game)
            g.running = false;
        break;
    case 'q':
        g.quit_prompt = true;
        break;
    case 'y':
        if (g.quit_prompt)
            g.running = false;
        break;
    case 'n':
        g.quit_prompt = false;
        break;
    case 'r':
        if (g.post_game)
            g.restart_requested = true;
        break;
    case 't':
        if (g.post_game)
            go_to_title(g);
        break;
    case 'b':
        apply_bomb(g);
        break;
    case 'e':
        dash_player(g);
        break;
    case 'f':
        g.auto_fire = !g.auto_fire;
        break;
    case 'h':
        g.show_help = !g.show_help;
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
        g.last_move_dx = -1;
        g.last_move_dy = 0;
        break;
    case KEY_RIGHT:
    case 'd':
        if (g.player.x < g.width - 2)
            g.player.x += 1;
        g.last_move_dx = 1;
        g.last_move_dy = 0;
        break;
    case KEY_UP:
    case 'w':
        if (g.player.y > 1)
            g.player.y -= 1;
        g.last_move_dx = 0;
        g.last_move_dy = -1;
        break;
    case KEY_DOWN:
    case 's':
        if (g.player.y < g.height - 2)
            g.player.y += 1;
        g.last_move_dx = 0;
        g.last_move_dy = 1;
        break;
    default:
        break;
    }
}

static void set_banner(GameState &g, const std::string &text, double duration_ms)
{
    g.banner_text = text;
    g.banner_until_ms = game_now(g) + duration_ms;
}

static void update_entities(GameState &g)
{
    std::uniform_real_distribution<double> chance(0.0, 1.0);
    double t = game_now(g);
    bool slow_active = t < g.slow_until_ms;
    bool slow_step = slow_active && ((static_cast<long>(t) / 120) % 2 == 0);
    // spawn batches by wave
    bool boss_alive = std::any_of(g.entities.begin(), g.entities.end(), [](const Entity &e){ return e.alive && e.type == EntityType::Boss; });
    if (!boss_alive && t > g.next_wave_ms && g.wave <= g.total_waves)
    {
        int enemies_to_spawn = 3 + g.wave;
        if (g.wave % 5 == 0)
        {
            spawn_boss(g);
            set_banner(g, "Boss wave!", 2000.0);
        }
        else
        {
            int kamikaze_count = std::max(1, g.wave / 3);
            int sniper_count = std::max(1, g.wave / 4);
            for (int i = 0; i < enemies_to_spawn; ++i)
                spawn_enemy(g, 1 - i); // staggered vertically
            for (int i = 0; i < kamikaze_count; ++i)
                spawn_kamikaze(g, 1 - i);
            for (int i = 0; i < sniper_count; ++i)
                spawn_sniper(g, 1 - i);
            set_banner(g, "Wave " + std::to_string(g.wave), 1500.0);
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
            if (!slow_step)
            {
                e.x += e.vx;
                e.y += e.vy;
            }
            if (e.x <= 1 || e.x >= g.width - 2)
                e.vx = -e.vx;
            if (t > e.next_action_ms)
            {
                enemy_fire(g, e);
                double extra = slow_active ? 350.0 : 0.0;
                e.next_action_ms = t + std::max(500.0, 1500.0 - (g.wave * 50.0) + extra);
            }
        }
        else if (e.type == EntityType::Kamikaze)
        {
            if (g.player.x < e.x)
                e.vx = -1;
            else if (g.player.x > e.x)
                e.vx = 1;
            else
                e.vx = 0;
            if (!slow_step)
            {
                e.x += e.vx;
                e.y += e.vy + 1;
            }
        }
        else if (e.type == EntityType::Sniper)
        {
            if (!slow_step)
                e.y += e.vy;
            if (t > e.next_action_ms)
            {
                int dx = 0;
                if (g.player.x < e.x)
                    dx = -1;
                else if (g.player.x > e.x)
                    dx = 1;
                Entity b{e.x, e.y + 1, dx, 1, EntityType::EnemyBullet, true, 0.0, 1};
                b.max_hp = b.hp;
                g.entities.push_back(b);
                double extra = slow_active ? 400.0 : 0.0;
                e.next_action_ms = t + std::max(700.0, 1400.0 - (g.wave * 40.0) + extra);
            }
        }
        else if (e.type == EntityType::Boss)
        {
            if (!e.enraged && e.hp <= e.max_hp / 2)
            {
                e.enraged = true;
                set_banner(g, "Boss enraged!", 1800.0);
            }
            if (!slow_step)
                e.x += e.vx;
            if (e.x <= 2 || e.x >= g.width - 3)
                e.vx = -e.vx;
            if (t > e.next_action_ms)
            {
                // triple shot
                Entity b1{e.x, e.y + 1, -1, 1, EntityType::EnemyBullet, true, 0.0, 1};
                Entity b2{e.x, e.y + 1, 0, 1, EntityType::EnemyBullet, true, 0.0, 1};
                Entity b3{e.x, e.y + 1, 1, 1, EntityType::EnemyBullet, true, 0.0, 1};
                b1.max_hp = b1.hp;
                b2.max_hp = b2.hp;
                b3.max_hp = b3.hp;
                g.entities.push_back(b1);
                g.entities.push_back(b2);
                g.entities.push_back(b3);
                if (e.enraged)
                {
                    std::uniform_int_distribution<int> spawn_roll(0, 99);
                    if (spawn_roll(g.rng) < 35)
                        spawn_kamikaze(g, e.y + 1);
                }
                double base_cd = e.enraged ? 650.0 : 900.0;
                double extra = slow_active ? 300.0 : 0.0;
                e.next_action_ms = t + std::max(250.0, base_cd - (g.wave * 30.0) + extra);
            }
        }
        else if (e.type == EntityType::PlayerBullet)
        {
            e.y += e.vy;
            e.x += e.vx;
        }
        else if (e.type == EntityType::EnemyBullet)
        {
            if (!slow_step)
            {
                e.y += e.vy;
                e.x += e.vx;
            }
        }
        else if (e.type == EntityType::Powerup)
        {
            if (!slow_step)
                e.y += e.vy;
        }
        if (e.y <= 0 || e.y >= g.height - 1)
            e.alive = false;
        if (e.x <= 0 || e.x >= g.width - 1)
            e.alive = false;
    }
}

static void handle_collisions(GameState &g)
{
    double t = game_now(g);
    for (auto &bullet : g.entities)
    {
        if (!bullet.alive || bullet.type != EntityType::PlayerBullet)
            continue;
        for (auto &enemy : g.entities)
        {
            if (!enemy.alive || (enemy.type != EntityType::Enemy && enemy.type != EntityType::Kamikaze && enemy.type != EntityType::Sniper && enemy.type != EntityType::Boss))
                continue;
            if (bullet.x == enemy.x && bullet.y == enemy.y)
            {
                bullet.alive = false;
                enemy.hp -= 1;
                if (enemy.hp <= 0)
                {
                    enemy.alive = false;
                    int base_score = (enemy.type == EntityType::Boss) ? 300
                                     : (enemy.type == EntityType::Sniper ? 25
                                        : (enemy.type == EntityType::Kamikaze ? 15 : 10));
                    if (t <= g.combo_until_ms)
                        g.combo_count += 1;
                    else
                        g.combo_count = 1;
                    g.combo_until_ms = t + 2000.0;
                    int bonus = base_score * g.combo_count / 5;
                    g.score += base_score + bonus;
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
        if ((e.type == EntityType::Enemy || e.type == EntityType::Kamikaze || e.type == EntityType::Sniper || e.type == EntityType::EnemyBullet) &&
            e.x == g.player.x && e.y == g.player.y && t > g.invuln_until_ms && t > g.shield_until_ms)
        {
            e.alive = false;
            g.lives -= 1;
            g.combo_count = 0;
            g.combo_until_ms = 0.0;
            g.invuln_until_ms = t + 1500.0; // 1.5s invuln
            g.player.x = g.width / 2;
            g.player.y = g.height - 3;
            if (g.lives <= 0)
                g.post_game = true;
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
            else if (e.power == PowerType::Spread)
            {
                g.spread_until_ms = t + 7000.0;
            }
            else if (e.power == PowerType::Slow)
            {
                g.slow_until_ms = t + 5000.0;
            }
            else if (e.power == PowerType::Bomb)
            {
                if (g.bombs < g.max_bombs)
                    g.bombs += 1;
                g.score += 25;
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
    if (g.in_title)
    {
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
        std::string title = "FT_SHMUP";
        std::string line1 = "Press SPACE/ENTER to start";
        std::string line2 = "Arrows/WASD move | Space shoot | f auto-fire";
        std::string line3 = "b bomb | e dash | m mode | p pause | q quit";
        std::string mode = g.infinite_mode ? "Mode: Endless" : "Mode: Campaign";
        int cx = std::max(1, (g.width / 2) - (int)title.size() / 2);
        int cy = g.height / 2 - 2;
        mvprintw(cy, cx, "%s", title.c_str());
        mvprintw(cy + 2, std::max(1, (g.width / 2) - (int)line1.size() / 2), "%s", line1.c_str());
        mvprintw(cy + 3, std::max(1, (g.width / 2) - (int)line2.size() / 2), "%s", line2.c_str());
        mvprintw(cy + 4, std::max(1, (g.width / 2) - (int)line3.size() / 2), "%s", line3.c_str());
        mvprintw(cy + 5, std::max(1, (g.width / 2) - (int)mode.size() / 2), "%s", mode.c_str());
        refresh();
        return;
    }
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
    char player_char = (g.shield_until_ms > game_now(g)) ? 'U' : 'A';
    if (g.dash_until_ms > game_now(g))
        player_char = 'D';
    mvaddch(g.player.y, g.player.x, player_char);
    for (const auto &e : g.entities)
    {
        if (!e.alive)
            continue;
        char c = '?';
        if (e.type == EntityType::Enemy)
            c = 'M';
        else if (e.type == EntityType::Kamikaze)
            c = 'K';
        else if (e.type == EntityType::Sniper)
            c = 'T';
        else if (e.type == EntityType::Boss)
            c = 'B';
        else if (e.type == EntityType::PlayerBullet)
            c = '|';
        else if (e.type == EntityType::EnemyBullet)
            c = 'v';
        else if (e.type == EntityType::Powerup)
        {
            if (e.power == PowerType::Life)
                c = '+';
            else if (e.power == PowerType::Shield)
                c = 'U';
            else if (e.power == PowerType::Rapid)
                c = 'R';
            else if (e.power == PowerType::Spread)
                c = 'S';
            else if (e.power == PowerType::Slow)
                c = 'Z';
            else
                c = 'B';
        }
        mvaddch(e.y, e.x, c);
    }
    mvprintw(g.height, 0, "Score:%d High:%d Lives:%d/%d Bombs:%d Wave:%d/%d Combo:%d  (h help, p pause, q quit)",
             g.score, g.high_score, g.lives, g.max_lives, g.bombs, g.wave, g.total_waves, g.combo_count);
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
    if (g.shield_until_ms > game_now(g))
        mvprintw(hud_line++, 0, "Shield active (%.1fs)", (g.shield_until_ms - game_now(g)) / 1000.0);
    if (g.rapid_until_ms > game_now(g))
        mvprintw(hud_line++, 0, "Rapid fire (%.1fs)", (g.rapid_until_ms - game_now(g)) / 1000.0);
    if (g.spread_until_ms > game_now(g))
        mvprintw(hud_line++, 0, "Spread shot (%.1fs)", (g.spread_until_ms - game_now(g)) / 1000.0);
    if (g.slow_until_ms > game_now(g))
        mvprintw(hud_line++, 0, "Slow time (%.1fs)", (g.slow_until_ms - game_now(g)) / 1000.0);
    if (g.dash_cd_until_ms > game_now(g))
        mvprintw(hud_line++, 0, "Dash CD (%.1fs)", (g.dash_cd_until_ms - game_now(g)) / 1000.0);
    else
        mvprintw(hud_line++, 0, "Dash ready");
    mvprintw(hud_line++, 0, "Auto-fire: %s", g.auto_fire ? "on" : "off");
    mvprintw(hud_line++, 0, "Mode: %s", g.infinite_mode ? "Endless" : "Campaign");
    if (g.show_help)
    {
        int help_line = 2;
        mvprintw(help_line++, g.width + 3, "Controls:");
        mvprintw(help_line++, g.width + 3, "Move: arrows / WASD");
        mvprintw(help_line++, g.width + 3, "Shoot: space");
        mvprintw(help_line++, g.width + 3, "Bomb: b");
        mvprintw(help_line++, g.width + 3, "Dash: e");
        mvprintw(help_line++, g.width + 3, "Auto-fire: f");
        mvprintw(help_line++, g.width + 3, "Pause: p");
        mvprintw(help_line++, g.width + 3, "Help: h");
        mvprintw(help_line++, g.width + 3, "Quit: q");
        mvprintw(help_line++, g.width + 3, "Power-ups:");
        mvprintw(help_line++, g.width + 3, "+ life, U shield, R rapid, S spread, Z slow, B bomb");
        mvprintw(help_line++, g.width + 3, "Enemies: M normal, K kamikaze, T sniper, B boss");
    }
    if (g.quit_prompt)
    {
        std::string msg = "Quit? (y/n)";
        int bx = std::max(1, (g.width / 2) - (int)msg.size() / 2);
        int by = g.height / 2;
        mvprintw(by, bx, "%s", msg.c_str());
    }
    if (g.post_game)
    {
        std::string msg = "Press r to restart or q to quit";
        int bx = std::max(1, (g.width / 2) - (int)msg.size() / 2);
        int by = g.height / 2 + 2;
        mvprintw(by, bx, "%s", msg.c_str());
        std::string status = g.victory ? "Victory! x to finish" : "Game Over! x to finish";
        int sx = std::max(1, (g.width / 2) - (int)status.size() / 2);
        int sy = by + 2;
        mvprintw(sy, sx, "%s", status.c_str());
    }
    if (!g.banner_text.empty() && game_now(g) < g.banner_until_ms)
    {
        int bx = std::max(1, (g.width / 2) - (int)g.banner_text.size() / 2);
        int by = 2;
        mvprintw(by, bx, "%s", g.banner_text.c_str());
    }
    refresh();
}

static void init_game(GameState &g, int width, int height)
{
    g.width = width;
    g.height = height;
    g.player.x = g.width / 2;
    g.player.y = g.height - 3;
    g.player.vx = 0;
    g.player.vy = 0;
    g.player.type = EntityType::Player;
    g.player.alive = true;
    g.entities.clear();
    g.stars.clear();
    g.lives = 3;
    g.bombs = 1;
    g.score = 0;
    g.victory = false;
    g.running = true;
    g.paused = false;
    g.show_help = false;
    g.post_game = false;
    g.restart_requested = false;
    g.in_title = false;
    g.quit_prompt = false;
    g.banner_until_ms = 0.0;
    g.banner_text.clear();
    g.combo_count = 0;
    g.combo_until_ms = 0.0;
    g.game_time_ms = 0.0;
    g.last_real_ms = now_ms();
    g.last_move_dx = 0;
    g.last_move_dy = -1;
    g.dash_until_ms = 0.0;
    g.dash_cd_until_ms = 0.0;
    g.auto_fire = false;
    g.total_waves = g.infinite_mode ? 9999 : 15;
    g.last_shot_ms = 0.0;
    g.last_enemy_spawn_ms = 0.0;
    g.wave = 1;
    g.next_wave_ms = 0.0;
    g.invuln_until_ms = 0.0;
    g.shield_until_ms = 0.0;
    g.rapid_until_ms = 0.0;
    g.spread_until_ms = 0.0;
    g.slow_until_ms = 0.0;
}

static void go_to_title(GameState &g)
{
    init_game(g, g.width, g.height);
    g.in_title = true;
}

int main()
{
    GameState g;
    int rows, cols;
    init_ncurses();
    getmaxyx(stdscr, rows, cols);
    int width = std::min(60, cols - 2);
    int height = std::min(22, rows - 3);
    if (width < 20 || height < 12)
    {
        shutdown_ncurses();
        fprintf(stderr, "Terminal too small (need at least 20x12 usable). Resize and retry.\n");
        return 1;
    }
    load_high_scores(g);
    g.rng.seed(std::random_device{}());
    init_game(g, width, height);
    go_to_title(g);
    auto last_frame = std::chrono::steady_clock::now();
    while (g.running)
    {
        handle_input(g);
        double real_now = now_ms();
        double delta_ms = real_now - g.last_real_ms;
        if (delta_ms < 0)
            delta_ms = 0.0;
        g.last_real_ms = real_now;
        if (!g.paused && !g.post_game)
            g.game_time_ms += delta_ms;
        if (!g.paused && !g.post_game && g.auto_fire)
            fire_player(g);
        if (!g.paused && !g.post_game)
        {
            scroll_background(g);
            update_entities(g);
            handle_collisions(g);
            cleanup_entities(g);
            bool enemies_left = std::any_of(g.entities.begin(), g.entities.end(), [](const Entity &e)
            { return e.alive && (e.type == EntityType::Enemy || e.type == EntityType::Kamikaze || e.type == EntityType::Sniper || e.type == EntityType::Boss || e.type == EntityType::EnemyBullet || e.type == EntityType::Powerup); });
            if (!g.infinite_mode && !enemies_left && g.wave > g.total_waves)
            {
                g.victory = true;
                g.post_game = true;
            }
            if (!g.running)
                g.post_game = true;
        }
        render(g);
        if (g.post_game && g.restart_requested)
        {
            init_game(g, width, height);
            g.restart_requested = false;
        }
        if (g.post_game && !g.running)
            break;
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
