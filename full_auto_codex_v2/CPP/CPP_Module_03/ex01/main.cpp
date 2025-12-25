#include "ScavTrap.hpp"

int main()
{
	ScavTrap a("ScavA");
	ScavTrap b(a);
	ScavTrap c;
	c = b;

	a.attack("target");
	a.guardGate();
	return 0;
}
