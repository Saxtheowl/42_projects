#ifndef ZOMBIE_HPP
#define ZOMBIE_HPP

#include <string>

class Zombie
{
private:
    std::string m_name;

public:
    Zombie(const std::string &name);
    ~Zombie();

    void announce() const;
};

Zombie *newZombie(const std::string &name);
void randomChump(const std::string &name);

#endif
