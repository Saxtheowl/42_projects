/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Array.hpp                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef ARRAY_HPP
# define ARRAY_HPP

# include <exception>
# include <cstddef>

template<typename T>
class Array
{
private:
	T*		_data;
	size_t	_size;

public:
	Array(void) : _data(NULL), _size(0) {}
	Array(unsigned int n) : _data(new T[n]()), _size(n) {}
	Array(const Array& other) : _data(NULL), _size(0) { *this = other; }
	Array& operator=(const Array& other) {
		if (this != &other) {
			delete[] _data;
			_size = other._size;
			_data = new T[_size];
			for (size_t i = 0; i < _size; i++) _data[i] = other._data[i];
		}
		return (*this);
	}
	~Array(void) { delete[] _data; }

	T& operator[](size_t index) {
		if (index >= _size) throw std::exception();
		return (_data[index]);
	}
	const T& operator[](size_t index) const {
		if (index >= _size) throw std::exception();
		return (_data[index]);
	}
	size_t size(void) const { return (_size); }
};

#endif
