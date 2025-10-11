#ifndef FIXED_HPP
#define FIXED_HPP

#include <iosfwd>

class Fixed
{
private:
    int                 m_raw;
    static const int    s_fractionalBits;

public:
    Fixed();
    Fixed(const Fixed &other);
    explicit Fixed(int value);
    explicit Fixed(float value);
    Fixed &operator=(const Fixed &other);
    ~Fixed();

    int   getRawBits() const;
    void  setRawBits(int const raw);
    float toFloat() const;
    int   toInt() const;
};

std::ostream &operator<<(std::ostream &os, const Fixed &value);

#endif
