#ifndef VALUE_HPP
#define VALUE_HPP

#include "Complex.hpp"
#include "Matrix.hpp"

#include <string>

class Value
{
public:
    enum Type
    {
        NUMBER,
        MATRIX,
        NONE
    };

private:
    Type   m_type;
    Complex m_number;
    Matrix  m_matrix;

public:
    Value();
    explicit Value(const Complex &number);
    explicit Value(const Matrix &matrix);

    Type getType() const;
    const Complex &getNumber() const;
    const Matrix &getMatrix() const;

    std::string toString(int precision = 6) const;

    Value operator+(const Value &other) const;
    Value operator-(const Value &other) const;
    Value operator*(const Value &other) const;
    Value operator/(const Value &other) const;
};

#endif
