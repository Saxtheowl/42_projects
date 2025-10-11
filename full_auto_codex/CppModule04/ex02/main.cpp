#include "Animal.hpp"
#include "Cat.hpp"
#include "Dog.hpp"

#include <iostream>

int main()
{
    const int count = 4;
    Animal *animals[count];

    for (int i = 0; i < count; ++i)
    {
        if (i < count / 2)
            animals[i] = new Dog();
        else
            animals[i] = new Cat();
    }

    for (int i = 0; i < count; ++i)
        animals[i]->makeSound();

    // Deep copy test
    Cat original;
    original.getBrain().setIdea(0, "Chase mice");

    Cat copy = original;
    original.getBrain().setIdea(0, "Sleep all day");

    std::cout << "Original idea: " << original.getBrain().getIdea(0) << std::endl;
    std::cout << "Copied idea: " << copy.getBrain().getIdea(0) << std::endl;

    for (int i = 0; i < count; ++i)
        delete animals[i];

    return 0;
}
