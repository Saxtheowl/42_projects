#include "Zombie.hpp"

#include <sstream>

Zombie *zombieHorde(int N, const std::string &name)
{
    if (N <= 0)
        return 0;
    Zombie *horde = new Zombie[N];
    for (int i = 0; i < N; ++i)
    {
        std::ostringstream label;
        label << name << "_" << i;
        horde[i].setName(label.str());
    }
    return horde;
}
