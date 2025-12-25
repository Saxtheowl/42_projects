#include "Brain.hpp"

#include <iostream>

Brain::Brain()
{
	std::cout << "Brain ctor" << std::endl;
}

Brain::Brain(const Brain &other)
{
	std::cout << "Brain copy ctor" << std::endl;
	*this = other;
}

Brain &Brain::operator=(const Brain &other)
{
	std::cout << "Brain copy assign" << std::endl;
	if (this != &other)
	{
		for (int i = 0; i < 100; ++i)
			_ideas[i] = other._ideas[i];
	}
	return *this;
}

Brain::~Brain()
{
	std::cout << "Brain dtor" << std::endl;
}

const std::string &Brain::getIdea(int index) const
{
	static const std::string empty;
	if (index < 0 || index >= 100)
		return empty;
	return _ideas[index];
}

void Brain::setIdea(int index, const std::string &idea)
{
	if (index < 0 || index >= 100)
		return;
	_ideas[index] = idea;
}
