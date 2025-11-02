#include <iostream>
#include <string>

#ifdef USE_FT
# include "ft/list.hpp"
# include "ft/stack.hpp"
# include "ft/queue.hpp"
namespace ns = ft;
#else
# include <list>
# include <stack>
# include <queue>
namespace ns = std;
#endif

static void print_list(const ns::list<std::string> &lst, const std::string &label)
{
	typedef ns::list<std::string>::const_iterator const_iterator;
	std::cout << label << ':';
	for (const_iterator it = lst.begin(); it != lst.end(); ++it)
		std::cout << ' ' << *it;
	std::cout << '\n';
}

int main()
{
	ns::list<std::string> fruits;
	fruits.push_back("banana");
	fruits.push_back("apple");
	fruits.push_back("pear");
	fruits.push_front("cherry");
	print_list(fruits, "initial");

	fruits.sort();
	print_list(fruits, "sorted");

	fruits.unique();
	print_list(fruits, "unique");

	ns::list<std::string> tropical;
	tropical.push_back("mango");
	tropical.push_back("papaya");
	fruits.merge(tropical);
	print_list(fruits, "merged");

	fruits.reverse();
	print_list(fruits, "reversed");

	ns::stack<int> numbers;
	for (int i = 0; i < 5; ++i)
		numbers.push(i * i);
	std::cout << "stack:";
	while (!numbers.empty())
	{
		std::cout << ' ' << numbers.top();
		numbers.pop();
	}
	std::cout << '\n';

	ns::queue<std::string> names;
	names.push("Alice");
	names.push("Bob");
	names.push("Charlie");
	std::cout << "queue front=" << names.front()
	          << " back=" << names.back() << '\n';
	while (!names.empty())
	{
		std::cout << names.front() << ' ';
		names.pop();
	}
	std::cout << '\n';

	return 0;
}
