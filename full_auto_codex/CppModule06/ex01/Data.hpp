#ifndef DATA_HPP
#define DATA_HPP

#include <stdint.h>
#include <string>

struct Data
{
    int         id;
    std::string name;
};

uintptr_t serialize(Data *ptr);
Data *deserialize(uintptr_t raw);

#endif
