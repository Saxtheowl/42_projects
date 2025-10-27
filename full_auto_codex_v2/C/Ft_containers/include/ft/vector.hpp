#pragma once

#include <cstddef>
#include <memory>
#include <stdexcept>
#include "iterator.hpp"
#include "type_traits.hpp"
#include "algorithm.hpp"
#include "utility.hpp"

namespace ft
{
	template <typename T, typename Allocator = std::allocator<T> >
	class vector
	{
	public:
		typedef T value_type;
		typedef Allocator allocator_type;
		typedef typename allocator_type::reference reference;
		typedef typename allocator_type::const_reference const_reference;
		typedef typename allocator_type::pointer pointer;
		typedef typename allocator_type::const_pointer const_pointer;
		typedef std::ptrdiff_t difference_type;
		typedef std::size_t size_type;
		typedef pointer iterator;
		typedef const_pointer const_iterator;
		typedef ft::reverse_iterator<iterator> reverse_iterator;
		typedef ft::reverse_iterator<const_iterator> const_reverse_iterator;

	private:
		allocator_type _alloc;
		pointer		   _data;
		size_type	   _size;
		size_type	   _capacity;

		void destroy_elements()
		{
			for (size_type i = 0; i < _size; ++i)
				_alloc.destroy(_data + i);
			_size = 0;
		}

		size_type recommend_capacity(size_type new_size) const
		{
			size_type cap = _capacity ? _capacity : 1;
			while (cap < new_size)
			{
				if (cap > max_size() / 2)
					return new_size;
				cap *= 2;
			}
			return cap;
		}

		void reallocate(size_type new_cap)
		{
			pointer new_data = _alloc.allocate(new_cap);
			size_type i = 0;
			try
			{
				for (; i < _size; ++i)
					_alloc.construct(new_data + i, _data[i]);
			}
			catch (...)
			{
				for (size_type j = 0; j < i; ++j)
					_alloc.destroy(new_data + j);
				_alloc.deallocate(new_data, new_cap);
				throw;
			}
			destroy_elements();
			if (_capacity)
				_alloc.deallocate(_data, _capacity);
			_data = new_data;
			_capacity = new_cap;
			_size = i;
		}

		template <typename InputIter>
		size_type range_length(InputIter first, InputIter last)
		{
			return ft::distance(first, last);
		}

		void allocate_if_needed(size_type n)
		{
			if (n > _capacity)
			{
				if (n > max_size())
					throw std::length_error("vector capacity exceeds max_size");
				reallocate(n);
			}
		}

	public:
		explicit vector(const allocator_type &alloc = allocator_type())
		: _alloc(alloc), _data(NULL), _size(0), _capacity(0)
		{
		}

		explicit vector(size_type count, const value_type &value = value_type(),
			const allocator_type &alloc = allocator_type())
		: _alloc(alloc), _data(NULL), _size(0), _capacity(0)
		{
			if (count > 0)
			{
				allocate_if_needed(count);
				for (; _size < count; ++_size)
					_alloc.construct(_data + _size, value);
			}
		}

		template <typename InputIt>
		vector(InputIt first, InputIt last,
			const allocator_type &alloc = allocator_type(),
			typename ft::enable_if<!ft::is_integral<InputIt>::value>::type * = 0)
		: _alloc(alloc), _data(NULL), _size(0), _capacity(0)
		{
			assign(first, last);
		}

		vector(const vector &other)
		: _alloc(other._alloc), _data(NULL), _size(0), _capacity(0)
		{
			assign(other.begin(), other.end());
		}

		~vector()
		{
			destroy_elements();
			if (_capacity)
				_alloc.deallocate(_data, _capacity);
		}

		vector &operator=(const vector &other)
		{
			if (this != &other)
				assign(other.begin(), other.end());
			return *this;
		}

		allocator_type get_allocator() const
		{
			return _alloc;
		}

		// Iterators
		iterator begin()
		{
			return _data;
		}

		const_iterator begin() const
		{
			return _data;
		}

		iterator end()
		{
			return _data + _size;
		}

		const_iterator end() const
		{
			return _data + _size;
		}

		reverse_iterator rbegin()
		{
			return reverse_iterator(end());
		}

		const_reverse_iterator rbegin() const
		{
			return const_reverse_iterator(end());
		}

		reverse_iterator rend()
		{
			return reverse_iterator(begin());
		}

		const_reverse_iterator rend() const
		{
			return const_reverse_iterator(begin());
		}

		// Capacity
		size_type size() const
		{
			return _size;
		}

		size_type max_size() const
		{
			return _alloc.max_size();
		}

		void resize(size_type count, value_type value = value_type())
		{
			if (count < _size)
			{
				while (_size > count)
				{
					--_size;
					_alloc.destroy(_data + _size);
				}
			}
			else if (count > _size)
			{
				reserve(count);
				while (_size < count)
				{
					_alloc.construct(_data + _size, value);
					++_size;
				}
			}
		}

		size_type capacity() const
		{
			return _capacity;
		}

		bool empty() const
		{
			return _size == 0;
		}

		void reserve(size_type new_cap)
		{
			if (new_cap > _capacity)
			{
				if (new_cap > max_size())
					throw std::length_error("vector::reserve");
				reallocate(new_cap);
			}
		}

		// Element access
		reference operator[](size_type pos)
		{
			return _data[pos];
		}

		const_reference operator[](size_type pos) const
		{
			return _data[pos];
		}

		reference at(size_type pos)
		{
			if (pos >= _size)
				throw std::out_of_range("vector::at");
			return _data[pos];
		}

		const_reference at(size_type pos) const
		{
			if (pos >= _size)
				throw std::out_of_range("vector::at const");
			return _data[pos];
		}

		reference front()
		{
			return _data[0];
		}

		const_reference front() const
		{
			return _data[0];
		}

		reference back()
		{
			return _data[_size - 1];
		}

		const_reference back() const
		{
			return _data[_size - 1];
		}

		value_type *data()
		{
			return _data;
		}

		const value_type *data() const
		{
			return _data;
		}

		// Modifiers
		void assign(size_type count, const value_type &value)
		{
			destroy_elements();
			if (count > _capacity)
				reallocate(count);
			for (; _size < count; ++_size)
				_alloc.construct(_data + _size, value);
		}

		template <typename InputIt>
		void assign(InputIt first, InputIt last,
			typename ft::enable_if<!ft::is_integral<InputIt>::value>::type * = 0)
		{
			size_type count = range_length(first, last);
			destroy_elements();
			if (count > _capacity)
			{
				if (_capacity)
					_alloc.deallocate(_data, _capacity);
				_data = _alloc.allocate(count);
				_capacity = count;
			}
			for (; first != last; ++first)
			{
				_alloc.construct(_data + _size, *first);
				++_size;
			}
		}

		void push_back(const value_type &value)
		{
			if (_size == _capacity)
				reserve(recommend_capacity(_size ? _size + 1 : 1));
			_alloc.construct(_data + _size, value);
			++_size;
		}

		void pop_back()
		{
			if (_size)
			{
				--_size;
				_alloc.destroy(_data + _size);
			}
		}

		iterator insert(iterator pos, const value_type &value)
		{
			size_type idx = pos - begin();
			insert(pos, size_type(1), value);
			return begin() + idx;
		}

		void insert(iterator pos, size_type count, const value_type &value)
		{
			if (count == 0)
				return;
			size_type idx = pos - begin();
			if (_size + count > _capacity)
				reserve(recommend_capacity(_size + count));
			for (size_type i = _size; i > idx; --i)
			{
				size_type dest = (i - 1) + count;
				if (dest >= _size)
					_alloc.construct(_data + dest, _data[i - 1]);
				else
					_data[dest] = _data[i - 1];
			}
			for (size_type i = 0; i < count; ++i)
			{
				size_type target = idx + i;
				if (target >= _size)
					_alloc.construct(_data + target, value);
				else
					_data[target] = value;
			}
			_size += count;
		}

		template <typename InputIt>
		void insert(iterator pos, InputIt first, InputIt last,
			typename ft::enable_if<!ft::is_integral<InputIt>::value>::type * = 0)
		{
			size_type idx = pos - begin();
			size_type count = range_length(first, last);
			if (count == 0)
				return;
			if (_size + count > _capacity)
				reserve(recommend_capacity(_size + count));
			pos = begin() + idx;
			for (size_type i = _size; i > idx; --i)
			{
				size_type dest = i - 1 + count;
				if (dest >= _size)
					_alloc.construct(_data + dest, _data[i - 1]);
				else
					_data[dest] = _data[i - 1];
			}
			for (; first != last; ++first, ++idx)
			{
				if (idx >= _size)
					_alloc.construct(_data + idx, *first);
				else
					_data[idx] = *first;
			}
			_size += count;
		}

		iterator erase(iterator pos)
		{
			return erase(pos, pos + 1);
		}

		iterator erase(iterator first, iterator last)
		{
			size_type idx = first - begin();
			size_type count = last - first;
			if (count == 0)
				return begin() + idx;
			for (size_type i = 0; i < _size - idx - count; ++i)
				_data[idx + i] = _data[idx + i + count];
			for (size_type i = 0; i < count; ++i)
			{
				--_size;
				_alloc.destroy(_data + _size);
			}
			return begin() + idx;
		}

		void swap(vector &other)
		{
			ft::swap(_alloc, other._alloc);
			ft::swap(_data, other._data);
			ft::swap(_size, other._size);
			ft::swap(_capacity, other._capacity);
		}

		void clear()
		{
			destroy_elements();
		}

	};

	template <typename T, typename Alloc>
	bool operator==(const vector<T, Alloc> &lhs, const vector<T, Alloc> &rhs)
	{
		if (lhs.size() != rhs.size())
			return false;
		return ft::equal(lhs.begin(), lhs.end(), rhs.begin());
	}

	template <typename T, typename Alloc>
	bool operator!=(const vector<T, Alloc> &lhs, const vector<T, Alloc> &rhs)
	{
		return !(lhs == rhs);
	}

	template <typename T, typename Alloc>
	bool operator<(const vector<T, Alloc> &lhs, const vector<T, Alloc> &rhs)
	{
		return ft::lexicographical_compare(lhs.begin(), lhs.end(),
			rhs.begin(), rhs.end());
	}

	template <typename T, typename Alloc>
	bool operator<=(const vector<T, Alloc> &lhs, const vector<T, Alloc> &rhs)
	{
		return !(rhs < lhs);
	}

	template <typename T, typename Alloc>
	bool operator>(const vector<T, Alloc> &lhs, const vector<T, Alloc> &rhs)
	{
		return rhs < lhs;
	}

	template <typename T, typename Alloc>
	bool operator>=(const vector<T, Alloc> &lhs, const vector<T, Alloc> &rhs)
	{
		return !(lhs < rhs);
	}

	template <typename T, typename Alloc>
	void swap(vector<T, Alloc> &lhs, vector<T, Alloc> &rhs)
	{
		lhs.swap(rhs);
	}
}
