#include "Brain.hpp"

#include <iostream>

Brain::Brain()
{
    std::cout << "Brain constructed" << std::endl;
}

Brain::Brain(const Brain &other)
{
    std::cout << "Brain copy constructed" << std::endl;
    for (int i = 0; i < 100; ++i)
        m_ideas[i] = other.m_ideas[i];
}

Brain &Brain::operator=(const Brain &other)
{
    if (this != &other)
    {
        for (int i = 0; i < 100; ++i)
            m_ideas[i] = other.m_ideas[i];
    }
    std::cout << "Brain copy assigned" << std::endl;
    return *this;
}

Brain::~Brain()
{
    std::cout << "Brain destroyed" << std::endl;
}

const std::string &Brain::getIdea(int index) const
{
    static std::string empty;
    if (index < 0 || index >= 100)
        return empty;
    return m_ideas[index];
}

void Brain::setIdea(int index, const std::string &idea)
{
    if (index < 0 || index >= 100)
        return;
    m_ideas[index] = idea;
}
