#include "FragTrap.hpp"
#include "ScavTrap.hpp"

int main()
{
    ScavTrap scav("GateKeeper");
    FragTrap frag("Fraggy");

    scav.attack("enemy");
    scav.guardGate();

    frag.attack("boss");
    frag.highFivesGuys();

    FragTrap clone(frag);
    clone.attack("another boss");

    return 0;
}
