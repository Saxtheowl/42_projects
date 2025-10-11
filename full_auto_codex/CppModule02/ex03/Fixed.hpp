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

    bool operator>(const Fixed &other) const;
    bool operator<(const Fixed &other) const;
    bool operator>=(const Fixed &other) const;
    bool operator<=(const Fixed &other) const;
    bool operator==(const Fixed &other) const;
    bool operator!=(const Fixed &other) const;

    Fixed operator+(const Fixed &other) const;
    Fixed operator-(const Fixed &other) const;
    Fixed operator*(const Fixed &other) const;
    Fixed operator/(const Fixed &other) const;

    Fixed &operator++();
    Fixed operator++(int);
    Fixed &operator--();
    Fixed operator--(int);

    static Fixed &min(Fixed &a, Fixed &b);
    static const Fixed &min(const Fixed &a, const Fixed &b);
    static Fixed &max(Fixed &a, Fixed &b);
    static const Fixed &max(const Fixed &a, const Fixed &b);
};

std::ostream &operator<<(std::ostream &os, const Fixed &value);

#endif
