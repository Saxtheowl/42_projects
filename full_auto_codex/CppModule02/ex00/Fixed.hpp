#ifndef FIXED_HPP
#define FIXED_HPP

class Fixed
{
private:
    int                 m_raw;
    static const int    s_fractionalBits;

public:
    Fixed();
    Fixed(const Fixed &other);
    Fixed &operator=(const Fixed &other);
    ~Fixed();

    int  getRawBits() const;
    void setRawBits(int const raw);
};

#endif
