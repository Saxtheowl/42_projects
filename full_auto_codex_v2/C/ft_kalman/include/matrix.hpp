#pragma once

#include <array>
#include <cstddef>
#include <initializer_list>
#include <stdexcept>

// Minimal fixed-size matrix for small dimensions (compile-time sizes).
// Intended for Kalman math; limited operations implemented as needed.
template <std::size_t Rows, std::size_t Cols>
class Matrix
{
public:
	Matrix()
	{
		data.fill(0.0);
	}

	Matrix(std::initializer_list<double> values)
	{
		if (values.size() != Rows * Cols)
			throw std::runtime_error("Initializer size mismatch");
		std::size_t i = 0;
		for (std::initializer_list<double>::const_iterator it = values.begin(); it != values.end(); ++it)
			data[i++] = *it;
	}

	double &operator()(std::size_t r, std::size_t c)
	{
		return data[r * Cols + c];
	}

	double operator()(std::size_t r, std::size_t c) const
	{
		return data[r * Cols + c];
	}

	static Matrix Identity()
	{
		Matrix m;
		const std::size_t dim = Rows < Cols ? Rows : Cols;
		for (std::size_t i = 0; i < dim; ++i)
			m(i, i) = 1.0;
		return m;
	}

	std::array<double, Rows * Cols> data;
};

template <std::size_t Rows, std::size_t Cols>
Matrix<Rows, Cols> operator+(const Matrix<Rows, Cols> &a, const Matrix<Rows, Cols> &b)
{
	Matrix<Rows, Cols> out;
	for (std::size_t i = 0; i < Rows * Cols; ++i)
		out.data[i] = a.data[i] + b.data[i];
	return out;
}

template <std::size_t Rows, std::size_t Cols>
Matrix<Rows, Cols> operator-(const Matrix<Rows, Cols> &a, const Matrix<Rows, Cols> &b)
{
	Matrix<Rows, Cols> out;
	for (std::size_t i = 0; i < Rows * Cols; ++i)
		out.data[i] = a.data[i] - b.data[i];
	return out;
}

template <std::size_t Rows, std::size_t Cols>
Matrix<Rows, Cols> operator*(double scalar, const Matrix<Rows, Cols> &m)
{
	Matrix<Rows, Cols> out;
	for (std::size_t i = 0; i < Rows * Cols; ++i)
		out.data[i] = scalar * m.data[i];
	return out;
}

template <std::size_t Rows, std::size_t Cols>
Matrix<Rows, Cols> operator*(const Matrix<Rows, Cols> &m, double scalar)
{
	return scalar * m;
}

template <std::size_t R, std::size_t C, std::size_t K>
Matrix<R, C> operator*(const Matrix<R, K> &a, const Matrix<K, C> &b)
{
	Matrix<R, C> out;
	for (std::size_t i = 0; i < R; ++i)
	{
		for (std::size_t j = 0; j < C; ++j)
		{
			double acc = 0.0;
			for (std::size_t k = 0; k < K; ++k)
				acc += a(i, k) * b(k, j);
			out(i, j) = acc;
		}
	}
	return out;
}

template <std::size_t Rows, std::size_t Cols>
Matrix<Cols, Rows> transpose(const Matrix<Rows, Cols> &m)
{
	Matrix<Cols, Rows> out;
	for (std::size_t r = 0; r < Rows; ++r)
		for (std::size_t c = 0; c < Cols; ++c)
			out(c, r) = m(r, c);
	return out;
}

// Determinant + inverse specialized for 3x3 measurement covariance matrix.
inline double determinant3x3(const Matrix<3, 3> &m)
{
	return m(0, 0) * (m(1, 1) * m(2, 2) - m(1, 2) * m(2, 1)) -
		   m(0, 1) * (m(1, 0) * m(2, 2) - m(1, 2) * m(2, 0)) +
		   m(0, 2) * (m(1, 0) * m(2, 1) - m(1, 1) * m(2, 0));
}

inline Matrix<3, 3> inverse3x3(const Matrix<3, 3> &m)
{
	const double det = determinant3x3(m);
	if (det == 0.0)
		throw std::runtime_error("Singular matrix (det=0)");
	const double invDet = 1.0 / det;
	Matrix<3, 3> inv;
	inv(0, 0) = invDet * (m(1, 1) * m(2, 2) - m(1, 2) * m(2, 1));
	inv(0, 1) = invDet * (m(0, 2) * m(2, 1) - m(0, 1) * m(2, 2));
	inv(0, 2) = invDet * (m(0, 1) * m(1, 2) - m(0, 2) * m(1, 1));
	inv(1, 0) = invDet * (m(1, 2) * m(2, 0) - m(1, 0) * m(2, 2));
	inv(1, 1) = invDet * (m(0, 0) * m(2, 2) - m(0, 2) * m(2, 0));
	inv(1, 2) = invDet * (m(0, 2) * m(1, 0) - m(0, 0) * m(1, 2));
	inv(2, 0) = invDet * (m(1, 0) * m(2, 1) - m(1, 1) * m(2, 0));
	inv(2, 1) = invDet * (m(0, 1) * m(2, 0) - m(0, 0) * m(2, 1));
	inv(2, 2) = invDet * (m(0, 0) * m(1, 1) - m(0, 1) * m(1, 0));
	return inv;
}
