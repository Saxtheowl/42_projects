#include "Zombie.hpp"

int main()
{
	Zombie *heap = newZombie("Heapster");
	heap->announce();
	delete heap;

	randomChump("Stacky");
	return 0;
}
