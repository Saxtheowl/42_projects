#ifndef SPAN_HPP
#define SPAN_HPP

#include <deque>
#include <stdexcept>

class Span
{
private:
    unsigned int    m_maxSize;
    std::deque<int> m_numbers;

public:
    Span(unsigned int n);
    Span(const Span &other);
    Span &operator=(const Span &other);
    ~Span();

    void addNumber(int value);
    template <typename InputIt>
    void addRange(InputIt first, InputIt last)
    {
        for (InputIt it = first; it != last; ++it)
            addNumber(*it);
    }

    unsigned int shortestSpan() const;
    unsigned int longestSpan() const;
};

#endif
