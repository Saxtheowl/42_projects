#ifndef MATRIX_HPP
#define MATRIX_HPP

#include "Complex.hpp"

#include <stdexcept>
#include <string>
#include <vector>

class Matrix
{
private:
    std::vector<std::vector<Complex> > m_data;

public:
    Matrix();
    explicit Matrix(const std::vector<std::vector<Complex> > &data);

    size_t rows() const;
    size_t cols() const;

    const Complex &at(size_t r, size_t c) const;
    Complex &at(size_t r, size_t c);

    std::string toString(int precision = 6) const;

    Matrix operator+(const Matrix &other) const;
    Matrix operator-(const Matrix &other) const;
    Matrix operator*(const Matrix &other) const;
    Matrix operator*(const Complex &scalar) const;
    Matrix operator/(const Complex &scalar) const;
    Matrix addScalar(const Complex &scalar) const;
    Matrix negate() const;
};

Matrix operator*(const Complex &scalar, const Matrix &matrix);

#endif
