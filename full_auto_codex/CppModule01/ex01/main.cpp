#include "Zombie.hpp"

#include <cstdlib>

int main()
{
    int size = 5;
    Zombie *horde = zombieHorde(size, "Walker");
    if (!horde)
        return EXIT_FAILURE;
    for (int i = 0; i < size; ++i)
        horde[i].announce();
    delete [] horde;
    return EXIT_SUCCESS;
}
