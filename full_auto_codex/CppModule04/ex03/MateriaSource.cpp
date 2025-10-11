#include "MateriaSource.hpp"

#include <iostream>

MateriaSource::MateriaSource()
{
    std::cout << "MateriaSource constructed" << std::endl;
    for (int i = 0; i < 4; ++i)
        m_storage[i] = 0;
}

MateriaSource::MateriaSource(const MateriaSource &other)
{
    std::cout << "MateriaSource copy constructed" << std::endl;
    for (int i = 0; i < 4; ++i)
    {
        if (other.m_storage[i])
            m_storage[i] = other.m_storage[i]->clone();
        else
            m_storage[i] = 0;
    }
}

MateriaSource &MateriaSource::operator=(const MateriaSource &other)
{
    if (this != &other)
    {
        for (int i = 0; i < 4; ++i)
        {
            delete m_storage[i];
            if (other.m_storage[i])
                m_storage[i] = other.m_storage[i]->clone();
            else
                m_storage[i] = 0;
        }
    }
    std::cout << "MateriaSource copy assigned" << std::endl;
    return *this;
}

MateriaSource::~MateriaSource()
{
    std::cout << "MateriaSource destroyed" << std::endl;
    for (int i = 0; i < 4; ++i)
        delete m_storage[i];
}

void MateriaSource::learnMateria(AMateria *m)
{
    if (!m)
        return;
    for (int i = 0; i < 4; ++i)
    {
        if (!m_storage[i])
        {
            m_storage[i] = m->clone();
            std::cout << "MateriaSource learned " << m->getType() << std::endl;
            delete m;
            return;
        }
    }
    std::cout << "MateriaSource storage full" << std::endl;
    delete m;
}

AMateria *MateriaSource::createMateria(const std::string &type)
{
    for (int i = 0; i < 4; ++i)
    {
        if (m_storage[i] && m_storage[i]->getType() == type)
        {
            std::cout << "MateriaSource creates " << type << std::endl;
            return m_storage[i]->clone();
        }
    }
    std::cout << "MateriaSource doesn't know materia of type " << type << std::endl;
    return 0;
}
