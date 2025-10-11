#include "Zombie.hpp"

int main()
{
    Zombie stackZombie("Stacky");
    stackZombie.announce();

    Zombie *heapZombie = newZombie("Heapy");
    heapZombie->announce();
    delete heapZombie;

    randomChump("Randomy");
    return 0;
}
