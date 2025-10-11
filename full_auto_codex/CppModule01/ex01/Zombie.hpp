#ifndef ZOMBIE_HPP
#define ZOMBIE_HPP

#include <string>

class Zombie
{
private:
    std::string m_name;

public:
    Zombie();
    explicit Zombie(const std::string &name);
    ~Zombie();

    void setName(const std::string &name);
    void announce() const;
};

Zombie *zombieHorde(int N, const std::string &name);

#endif
