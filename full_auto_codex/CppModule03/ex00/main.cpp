#include "ClapTrap.hpp"

int main()
{
    ClapTrap clap("CL4P-TP");
    clap.attack("Bandit");
    clap.takeDamage(4);
    clap.beRepaired(2);
    clap.takeDamage(20);
    clap.attack("Second target");
    clap.beRepaired(5);
    return 0;
}
