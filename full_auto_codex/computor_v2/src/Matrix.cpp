#include "Matrix.hpp"

Matrix::Matrix() {}

Matrix::Matrix(const std::vector<std::vector<Complex> > &data) : m_data(data)
{
    if (!m_data.empty())
    {
        size_t cols = m_data[0].size();
        for (size_t i = 1; i < m_data.size(); ++i)
        {
            if (m_data[i].size() != cols)
                throw std::runtime_error("Matrix rows must have same size");
        }
    }
}

size_t Matrix::rows() const
{
    return m_data.size();
}

size_t Matrix::cols() const
{
    return m_data.empty() ? 0 : m_data[0].size();
}

const Complex &Matrix::at(size_t r, size_t c) const
{
    if (r >= rows() || c >= cols())
        throw std::out_of_range("Matrix index out of bounds");
    return m_data[r][c];
}

Complex &Matrix::at(size_t r, size_t c)
{
    if (r >= rows() || c >= cols())
        throw std::out_of_range("Matrix index out of bounds");
    return m_data[r][c];
}

std::string Matrix::toString(int precision) const
{
    std::string result = "[";
    for (size_t r = 0; r < rows(); ++r)
    {
        if (r > 0)
            result += "; ";
        result += "[";
        for (size_t c = 0; c < cols(); ++c)
        {
            if (c > 0)
                result += ", ";
            result += m_data[r][c].toString(precision);
        }
        result += "]";
    }
    result += "]";
    return result;
}

Matrix Matrix::operator+(const Matrix &other) const
{
    if (rows() != other.rows() || cols() != other.cols())
        throw std::runtime_error("Matrix dimensions mismatch for addition");
    std::vector<std::vector<Complex> > data(rows(), std::vector<Complex>(cols()));
    for (size_t r = 0; r < rows(); ++r)
        for (size_t c = 0; c < cols(); ++c)
            data[r][c] = m_data[r][c] + other.m_data[r][c];
    return Matrix(data);
}

Matrix Matrix::operator-(const Matrix &other) const
{
    if (rows() != other.rows() || cols() != other.cols())
        throw std::runtime_error("Matrix dimensions mismatch for subtraction");
    std::vector<std::vector<Complex> > data(rows(), std::vector<Complex>(cols()));
    for (size_t r = 0; r < rows(); ++r)
        for (size_t c = 0; c < cols(); ++c)
            data[r][c] = m_data[r][c] - other.m_data[r][c];
    return Matrix(data);
}

Matrix Matrix::operator*(const Matrix &other) const
{
    if (cols() != other.rows())
        throw std::runtime_error("Matrix dimensions mismatch for multiplication");
    std::vector<std::vector<Complex> > data(rows(), std::vector<Complex>(other.cols(), Complex()));
    for (size_t r = 0; r < rows(); ++r)
    {
        for (size_t c = 0; c < other.cols(); ++c)
        {
            Complex sum;
            for (size_t k = 0; k < cols(); ++k)
                sum += m_data[r][k] * other.m_data[k][c];
            data[r][c] = sum;
        }
    }
    return Matrix(data);
}

Matrix Matrix::operator*(const Complex &scalar) const
{
    std::vector<std::vector<Complex> > data = m_data;
    for (size_t r = 0; r < rows(); ++r)
        for (size_t c = 0; c < cols(); ++c)
            data[r][c] = data[r][c] * scalar;
    return Matrix(data);
}

Matrix Matrix::operator/(const Complex &scalar) const
{
    std::vector<std::vector<Complex> > data = m_data;
    for (size_t r = 0; r < rows(); ++r)
        for (size_t c = 0; c < cols(); ++c)
            data[r][c] = data[r][c] / scalar;
    return Matrix(data);
}

Matrix Matrix::addScalar(const Complex &scalar) const
{
    std::vector<std::vector<Complex> > data = m_data;
    for (size_t r = 0; r < rows(); ++r)
        for (size_t c = 0; c < cols(); ++c)
            data[r][c] = data[r][c] + scalar;
    return Matrix(data);
}

Matrix Matrix::negate() const
{
    return (*this) * Complex(-1.0);
}

Matrix operator*(const Complex &scalar, const Matrix &matrix)
{
    return matrix * scalar;
}
