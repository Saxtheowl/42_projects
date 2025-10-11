#include "ScavTrap.hpp"

int main()
{
    ScavTrap scav("Serena");
    scav.attack("intruder");
    scav.takeDamage(30);
    scav.beRepaired(20);
    scav.guardGate();

    ScavTrap copy(scav);
    copy.attack("another intruder");
    copy.takeDamage(120);
    copy.guardGate();

    return 0;
}
