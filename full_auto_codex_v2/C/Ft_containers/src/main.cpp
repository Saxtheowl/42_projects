#include <iostream>
#include "ft/config.hpp"
#include "ft/vector.hpp"

int main()
{
	std::cout << "ft_containers skeleton (version "
	          << ft::library_config::version() << ")" << std::endl;

	ft::vector<int> numbers;
	numbers.push_back(42);
	numbers.push_back(21);
	std::cout << "vector size=" << numbers.size()
	          << " front=" << numbers.front()
	          << " back=" << numbers.back() << std::endl;

	return 0;
}
