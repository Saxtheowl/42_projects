#include "Value.hpp"

#include <stdexcept>

Value::Value() : m_type(NONE), m_number(), m_matrix() {}
Value::Value(const Complex &number) : m_type(NUMBER), m_number(number), m_matrix() {}
Value::Value(const Matrix &matrix) : m_type(MATRIX), m_number(), m_matrix(matrix) {}

Value::Type Value::getType() const
{
    return m_type;
}

const Complex &Value::getNumber() const
{
    if (m_type != NUMBER)
        throw std::runtime_error("Value is not a number");
    return m_number;
}

const Matrix &Value::getMatrix() const
{
    if (m_type != MATRIX)
        throw std::runtime_error("Value is not a matrix");
    return m_matrix;
}

std::string Value::toString(int precision) const
{
    if (m_type == NUMBER)
        return m_number.toString(precision);
    if (m_type == MATRIX)
        return m_matrix.toString(precision);
    return "undefined";
}

Value Value::operator+(const Value &other) const
{
    if (m_type == NUMBER && other.m_type == NUMBER)
        return Value(m_number + other.m_number);
    if (m_type == MATRIX && other.m_type == MATRIX)
        return Value(m_matrix + other.m_matrix);
    if (m_type == MATRIX && other.m_type == NUMBER)
        return Value(m_matrix.addScalar(other.m_number));
    if (m_type == NUMBER && other.m_type == MATRIX)
        return Value(other.m_matrix.addScalar(m_number));
    throw std::runtime_error("Unsupported addition");
}

Value Value::operator-(const Value &other) const
{
    if (m_type == NUMBER && other.m_type == NUMBER)
        return Value(m_number - other.m_number);
    if (m_type == MATRIX && other.m_type == MATRIX)
        return Value(m_matrix - other.m_matrix);
    if (m_type == MATRIX && other.m_type == NUMBER)
        return Value(m_matrix.addScalar(other.m_number * Complex(-1.0)));
    if (m_type == NUMBER && other.m_type == MATRIX)
        return Value(other.m_matrix.negate().addScalar(m_number));
    throw std::runtime_error("Unsupported subtraction");
}

Value Value::operator*(const Value &other) const
{
    if (m_type == NUMBER && other.m_type == NUMBER)
        return Value(m_number * other.m_number);
    if (m_type == NUMBER && other.m_type == MATRIX)
        return Value(m_number * other.m_matrix);
    if (m_type == MATRIX && other.m_type == NUMBER)
        return Value(m_matrix * other.m_number);
    if (m_type == MATRIX && other.m_type == MATRIX)
        return Value(m_matrix * other.m_matrix);
    throw std::runtime_error("Unsupported multiplication");
}

Value Value::operator/(const Value &other) const
{
    if (m_type == NUMBER && other.m_type == NUMBER)
        return Value(m_number / other.m_number);
    if (m_type == MATRIX && other.m_type == NUMBER)
        return Value(m_matrix / other.m_number);
    throw std::runtime_error("Unsupported division");
}
