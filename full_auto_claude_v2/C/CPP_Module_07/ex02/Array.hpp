/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Array.hpp                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
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
	T*		elements;
	size_t	_size;

public:
	Array() : elements(NULL), _size(0) {}

	Array(unsigned int n) : elements(new T[n]()), _size(n) {}

	Array(Array const & other) : elements(NULL), _size(0)
	{
		*this = other;
	}

	Array& operator=(Array const & other)
	{
		if (this != &other)
		{
			delete[] this->elements;
			this->_size = other._size;
			if (this->_size > 0)
			{
				this->elements = new T[this->_size];
				for (size_t i = 0; i < this->_size; i++)
					this->elements[i] = other.elements[i];
			}
			else
				this->elements = NULL;
		}
		return (*this);
	}

	~Array()
	{
		delete[] this->elements;
	}

	T& operator[](size_t index)
	{
		if (index >= this->_size)
			throw std::exception();
		return (this->elements[index]);
	}

	T const & operator[](size_t index) const
	{
		if (index >= this->_size)
			throw std::exception();
		return (this->elements[index]);
	}

	size_t size() const
	{
		return (this->_size);
	}
};

#endif
