#include <iostream>
#include <string>

#ifdef USE_FT
# include "ft/vector.hpp"
namespace ns = ft;
#else
# include <vector>
namespace ns = std;
#endif

static void print_vector(const ns::vector<int> &v, const std::string &label)
{
    std::cout << label << " size=" << v.size();
    std::cout << " contents";
    for (ns::vector<int>::const_iterator it = v.begin(); it != v.end(); ++it)
        std::cout << ' ' << *it;
    std::cout << '\n';
}

int main()
{
    ns::vector<int> v;
    for (int i = 0; i < 5; ++i)
        v.push_back(i * 2);
    print_vector(v, "initial");

    v.insert(v.begin() + 2, 3, 99);
    print_vector(v, "after_insert");

    v.erase(v.begin() + 1, v.begin() + 4);
    print_vector(v, "after_erase");

    ns::vector<int> w;
    w.assign(v.begin(), v.end());
    w.push_back(777);

    print_vector(w, "copy_assign");
    return 0;
}
