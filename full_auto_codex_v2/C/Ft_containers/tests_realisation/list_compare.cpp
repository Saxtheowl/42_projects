#include <iostream>
#include <string>

#ifdef USE_FT
# include "ft/list.hpp"
namespace ns = ft;
#else
# include <list>
namespace ns = std;
#endif

static void print_list(const ns::list<int> &lst, const std::string &label)
{
    std::cout << label << " size=" << lst.size();
    std::cout << " contents";
    for (ns::list<int>::const_iterator it = lst.begin(); it != lst.end(); ++it)
        std::cout << ' ' << *it;
    std::cout << '\n';
}

int main()
{
    ns::list<int> lst;
    lst.push_back(1);
    lst.push_back(2);
    lst.push_front(0);
    print_list(lst, "initial");

    ns::list<int>::iterator it = lst.begin();
    ++it;
    lst.insert(it, 3, 99);
    print_list(lst, "after_insert");

    lst.remove(99);
    print_list(lst, "after_remove");

    ns::list<int> other;
    other.assign(2, 42);
    lst.splice(lst.end(), other);
    print_list(lst, "after_splice");

    lst.reverse();
    print_list(lst, "after_reverse");

    return 0;
}
