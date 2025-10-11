#include "DiamondTrap.hpp"

int main()
{
    DiamondTrap diamond("Diamond");
    diamond.attack("target");
    diamond.highFivesGuys();
    diamond.guardGate();
    diamond.whoAmI();

    DiamondTrap copy(diamond);
    copy.whoAmI();

    DiamondTrap assigned;
    assigned = diamond;
    assigned.whoAmI();

    return 0;
}
