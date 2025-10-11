#include "Data.hpp"

#include <iostream>

int main()
{
    Data original;
    original.id = 42;
    original.name = "The answer";

    uintptr_t raw = serialize(&original);
    Data *recovered = deserialize(raw);

    std::cout << "Original address: " << &original << std::endl;
    std::cout << "Recovered address: " << recovered << std::endl;
    std::cout << "Recovered id: " << recovered->id << std::endl;
    std::cout << "Recovered name: " << recovered->name << std::endl;

    return 0;
}
