#include <iostream>
#include <string>

#ifdef USE_FT
# include "ft/map.hpp"
namespace ns = ft;
#else
# include <map>
namespace ns = std;
#endif

static void print_map(const ns::map<int, std::string> &m, const std::string &label)
{
    std::cout << label << " size=" << m.size();
    for (ns::map<int, std::string>::const_iterator it = m.begin(); it != m.end(); ++it)
        std::cout << " (" << it->first << ':' << it->second << ')';
    std::cout << '\n';
}

int main()
{
    ns::map<int, std::string> m;
    m.insert(ns::make_pair(2, "two"));
    m.insert(ns::make_pair(1, "one"));
    m.insert(ns::make_pair(3, "three"));
    print_map(m, "initial");

    m.erase(2);
    print_map(m, "after_erase");

    ns::map<int, std::string> other;
    other.insert(ns::make_pair(4, "four"));
    other.insert(ns::make_pair(5, "five"));
    m.insert(other.begin(), other.end());
    print_map(m, "after_insert_range");

    std::cout << "lower_bound(3)=";
    ns::map<int, std::string>::const_iterator lb = m.lower_bound(3);
    if (lb != m.end())
        std::cout << lb->first << ':' << lb->second;
    std::cout << '\n';

    return 0;
}
