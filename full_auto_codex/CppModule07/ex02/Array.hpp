#ifndef ARRAY_HPP
#define ARRAY_HPP

#include <cstddef>
#include <stdexcept>

template <typename T>
class Array
{
private:
    T *m_data;
    unsigned int m_size;

public:
    Array();
    explicit Array(unsigned int n);
    Array(const Array &other);
    Array &operator=(const Array &other);
    ~Array();

    unsigned int size() const;
    T &operator[](unsigned int index);
    const T &operator[](unsigned int index) const;
};

#include "Array.tpp"

#endif
