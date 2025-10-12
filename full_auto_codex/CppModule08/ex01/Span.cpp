#include "Span.hpp"

#include <algorithm>

Span::Span(unsigned int n)
    : m_maxSize(n)
{
}

Span::Span(const Span &other)
    : m_maxSize(other.m_maxSize), m_numbers(other.m_numbers)
{
}

Span &Span::operator=(const Span &other)
{
    if (this != &other)
    {
        m_maxSize = other.m_maxSize;
        m_numbers = other.m_numbers;
    }
    return *this;
}

Span::~Span()
{
}

void Span::addNumber(int value)
{
    if (m_numbers.size() >= m_maxSize)
        throw std::runtime_error("Span is full");
    m_numbers.push_back(value);
}

unsigned int Span::shortestSpan() const
{
    if (m_numbers.size() < 2)
        throw std::runtime_error("Not enough numbers");
    std::deque<int> sorted = m_numbers;
    std::sort(sorted.begin(), sorted.end());
    unsigned int minSpan = static_cast<unsigned int>(-1);
    for (size_t i = 1; i < sorted.size(); ++i)
    {
        unsigned int diff = static_cast<unsigned int>(sorted[i] - sorted[i - 1]);
        if (diff < minSpan)
            minSpan = diff;
    }
    return minSpan;
}

unsigned int Span::longestSpan() const
{
    if (m_numbers.size() < 2)
        throw std::runtime_error("Not enough numbers");
    std::deque<int>::const_iterator minIt = std::min_element(m_numbers.begin(), m_numbers.end());
    std::deque<int>::const_iterator maxIt = std::max_element(m_numbers.begin(), m_numbers.end());
    return static_cast<unsigned int>(*maxIt - *minIt);
}
