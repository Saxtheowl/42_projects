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
		typedef T										  value_type;
		typedef Allocator								  allocator_type;
		typedef typename allocator_type::reference		  reference;
		typedef typename allocator_type::const_reference const_reference;
		typedef typename allocator_type::pointer		  pointer;
		typedef typename allocator_type::const_pointer	  const_pointer;
		typedef std::ptrdiff_t							  difference_type;
		typedef std::size_t								  size_type;
		typedef pointer									  iterator;
		typedef const_pointer							  const_iterator;
		typedef ft::reverse_iterator<iterator>			  reverse_iterator;
		typedef ft::reverse_iterator<const_iterator>	  const_reverse_iterator;

	private:
		allocator_type _alloc;
		pointer		   _begin;
		pointer		   _end;
		pointer		   _end_cap;

		pointer allocate(size_type n)
		{
			if (n == 0)
				return pointer();
			return _alloc.allocate(n);
		}

		void deallocate(pointer ptr, size_type n)
		{
			if (ptr)
				_alloc.deallocate(ptr, n);
		}

		void destroy_range(pointer first, pointer last)
		{
			while (first != last)
			{
				--last;
				_alloc.destroy(last);
			}
		}

		size_type current_size() const
		{
			if (!_begin)
				return 0;
			return static_cast<size_type>(_end - _begin);
		}

		size_type current_capacity() const
		{
			if (!_begin)
				return 0;
			return static_cast<size_type>(_end_cap - _begin);
		}

		size_type recommend(size_type new_size) const
		{
			size_type cap = capacity();
			if (new_size > max_size())
				throw std::length_error("ft::vector capacity overflow");
			if (cap >= new_size)
				return cap;
			size_type recommended = cap ? cap : 1;
			while (recommended < new_size)
			{
				if (recommended > max_size() / 2)
					return max_size();
				recommended *= 2;
			}
			return recommended;
		}

		size_type iterator_index(const_iterator it) const
		{
			if (!_begin)
				return 0;
			return static_cast<size_type>(it - _begin);
		}

		iterator pointer_at(size_type idx)
		{
			if (!_begin)
				return iterator();
			return _begin + idx;
		}

		const_iterator pointer_at(size_type idx) const
		{
			if (!_begin)
				return const_iterator();
			return _begin + idx;
		}

		template <typename InputIt>
		void assign_range(InputIt first, InputIt last, std::input_iterator_tag)
		{
			clear();
			for (; first != last; ++first)
				push_back(*first);
		}

		template <typename ForwardIt>
		void assign_range(ForwardIt first, ForwardIt last, std::forward_iterator_tag)
		{
			size_type count = ft::distance(first, last);
			if (count == 0)
			{
				clear();
				return;
			}
			if (count > max_size())
				throw std::length_error("ft::vector::assign");
			if (count > capacity())
			{
				pointer new_begin = allocate(count);
				pointer new_end = new_begin;
				try
				{
					for (; first != last; ++first, ++new_end)
						_alloc.construct(new_end, *first);
				}
				catch (...)
				{
					destroy_range(new_begin, new_end);
					deallocate(new_begin, count);
					throw;
				}
				size_type old_cap = capacity();
				destroy_range(_begin, _end);
				deallocate(_begin, old_cap);
				_begin = new_begin;
				_end = new_end;
				_end_cap = new_begin + count;
			}
			else
			{
				pointer dest = _begin;
				for (; first != last; ++first, ++dest)
				{
					if (dest < _end)
						*dest = *first;
					else
						_alloc.construct(dest, *first);
				}
				pointer new_end = _begin + count;
				destroy_range(new_end, _end);
				_end = new_end;
			}
		}

		void insert_buffer(size_type idx, pointer buffer_begin, pointer buffer_end)
		{
			size_type count = static_cast<size_type>(buffer_end - buffer_begin);
			if (count == 0)
				return;
			size_type old_size = size();
			size_type new_size = old_size + count;
			size_type new_cap = capacity() >= new_size ? capacity() : recommend(new_size);

			pointer new_begin = allocate(new_cap);
			pointer new_end = new_begin;
			try
			{
				for (size_type i = 0; i < idx; ++i, ++new_end)
					_alloc.construct(new_end, _begin[i]);
				for (pointer it = buffer_begin; it != buffer_end; ++it, ++new_end)
					_alloc.construct(new_end, *it);
				for (size_type i = idx; i < old_size; ++i, ++new_end)
					_alloc.construct(new_end, _begin[i]);
			}
			catch (...)
			{
				destroy_range(new_begin, new_end);
				deallocate(new_begin, new_cap);
				throw;
			}

			size_type old_cap = capacity();
			destroy_range(_begin, _end);
			deallocate(_begin, old_cap);
			_begin = new_begin;
			_end = new_begin + new_size;
			_end_cap = new_begin + new_cap;
		}

		template <typename InputIt>
		void insert_range(size_type idx, InputIt first, InputIt last,
			std::input_iterator_tag)
		{
			for (; first != last; ++first)
			{
				insert(pointer_at(idx), *first);
				++idx;
			}
		}

		template <typename ForwardIt>
		void insert_range(size_type idx, ForwardIt first, ForwardIt last,
			std::forward_iterator_tag)
		{
			size_type count = ft::distance(first, last);
			if (count == 0)
				return;
			if (size() + count > max_size())
				throw std::length_error("ft::vector::insert");

			pointer buffer = allocate(count);
			pointer buffer_end = buffer;
			try
			{
				for (; first != last; ++first, ++buffer_end)
					_alloc.construct(buffer_end, *first);
			}
			catch (...)
			{
				destroy_range(buffer, buffer_end);
				deallocate(buffer, count);
				throw;
			}

			try
			{
				insert_buffer(idx, buffer, buffer_end);
			}
			catch (...)
			{
				destroy_range(buffer, buffer_end);
				deallocate(buffer, count);
				throw;
			}

			destroy_range(buffer, buffer_end);
			deallocate(buffer, count);
		}

	public:
		explicit vector(const allocator_type &alloc = allocator_type())
		: _alloc(alloc), _begin(pointer()), _end(pointer()), _end_cap(pointer())
		{
		}

		explicit vector(size_type count, const value_type &value = value_type(),
			const allocator_type &alloc = allocator_type())
		: _alloc(alloc), _begin(pointer()), _end(pointer()), _end_cap(pointer())
		{
			if (count == 0)
				return;
			_begin = allocate(count);
			_end_cap = _begin + count;
			pointer current = _begin;
			try
			{
				for (; current != _end_cap; ++current)
					_alloc.construct(current, value);
			}
			catch (...)
			{
				destroy_range(_begin, current);
				deallocate(_begin, count);
				_begin = _end = _end_cap = pointer();
				throw;
			}
			_end = _begin + count;
		}

		template <typename InputIt>
		vector(InputIt first, InputIt last, const allocator_type &alloc = allocator_type(),
			typename ft::enable_if<!ft::is_integral<InputIt>::value>::type * = 0)
		: _alloc(alloc), _begin(pointer()), _end(pointer()), _end_cap(pointer())
		{
			assign(first, last);
		}

		vector(const vector &other)
		: _alloc(other._alloc), _begin(pointer()), _end(pointer()), _end_cap(pointer())
		{
			assign(other.begin(), other.end());
		}

		~vector()
		{
			destroy_range(_begin, _end);
			deallocate(_begin, capacity());
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

		iterator begin()
		{
			return _begin;
		}

		const_iterator begin() const
		{
			return _begin;
		}

		iterator end()
		{
			return _end;
		}

		const_iterator end() const
		{
			return _end;
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

		size_type size() const
		{
			return current_size();
		}

		size_type max_size() const
		{
			return _alloc.max_size();
		}

		void resize(size_type count, value_type value = value_type())
		{
			size_type current = size();
			if (count < current)
			{
				pointer new_end = _begin + count;
				destroy_range(new_end, _end);
				_end = new_end;
			}
			else if (count > current)
			{
				if (count > capacity())
					reserve(recommend(count));
				while (size() < count)
				{
					_alloc.construct(_end, value);
					++_end;
				}
			}
		}

		size_type capacity() const
		{
			return current_capacity();
		}

		bool empty() const
		{
			return size() == 0;
		}

		void reserve(size_type new_cap)
		{
			if (new_cap <= capacity())
				return;
			if (new_cap > max_size())
				throw std::length_error("ft::vector::reserve");

			pointer new_begin = allocate(new_cap);
			pointer new_end = new_begin;
			pointer it = _begin;
			try
			{
				for (; it != _end; ++it, ++new_end)
					_alloc.construct(new_end, *it);
			}
			catch (...)
			{
				destroy_range(new_begin, new_end);
				deallocate(new_begin, new_cap);
				throw;
			}

			size_type old_cap = capacity();
			destroy_range(_begin, _end);
			deallocate(_begin, old_cap);
			_begin = new_begin;
			_end = new_end;
			_end_cap = new_begin + new_cap;
		}

		reference operator[](size_type pos)
		{
			return _begin[pos];
		}

		const_reference operator[](size_type pos) const
		{
			return _begin[pos];
		}

		reference at(size_type pos)
		{
			if (pos >= size())
				throw std::out_of_range("ft::vector::at");
			return _begin[pos];
		}

		const_reference at(size_type pos) const
		{
			if (pos >= size())
				throw std::out_of_range("ft::vector::at");
			return _begin[pos];
		}

		reference front()
		{
			return *_begin;
		}

		const_reference front() const
		{
			return *_begin;
		}

		reference back()
		{
			return *(_end - 1);
		}

		const_reference back() const
		{
			return *(_end - 1);
		}

		value_type *data()
		{
			return _begin;
		}

		const value_type *data() const
		{
			return _begin;
		}

		void assign(size_type count, const value_type &value)
		{
			if (count == 0)
			{
				clear();
				return;
			}
			if (count > max_size())
				throw std::length_error("ft::vector::assign");
			if (count > capacity())
			{
				pointer new_begin = allocate(count);
				pointer new_end = new_begin;
				try
				{
					for (; new_end != new_begin + count; ++new_end)
						_alloc.construct(new_end, value);
				}
				catch (...)
				{
					destroy_range(new_begin, new_end);
					deallocate(new_begin, count);
					throw;
				}
				size_type old_cap = capacity();
				destroy_range(_begin, _end);
				deallocate(_begin, old_cap);
				_begin = new_begin;
				_end = new_begin + count;
				_end_cap = new_begin + count;
			}
			else
			{
				pointer dest = _begin;
				size_type i = 0;
				for (; i < count; ++i, ++dest)
				{
					if (dest < _end)
						*dest = value;
					else
						_alloc.construct(dest, value);
				}
				pointer new_end = _begin + count;
				destroy_range(new_end, _end);
				_end = new_end;
			}
		}

		template <typename InputIt>
		void assign(InputIt first, InputIt last,
			typename ft::enable_if<!ft::is_integral<InputIt>::value>::type * = 0)
		{
			typedef typename ft::iterator_traits<InputIt>::iterator_category category;
			assign_range(first, last, category());
		}

		void push_back(const value_type &value)
		{
			if (size() == capacity())
				reserve(recommend(size() + 1));
			_alloc.construct(_end, value);
			++_end;
		}

		void pop_back()
		{
			if (empty())
				return;
			--_end;
			_alloc.destroy(_end);
		}

		iterator insert(iterator pos, const value_type &value)
		{
			size_type idx = iterator_index(pos);
			insert(pos, size_type(1), value);
			return pointer_at(idx);
		}

		void insert(iterator pos, size_type count, const value_type &value)
		{
			if (count == 0)
				return;
			if (size() + count > max_size())
				throw std::length_error("ft::vector::insert");
			pointer buffer = allocate(count);
			pointer buffer_end = buffer;
			try
			{
				for (; buffer_end != buffer + count; ++buffer_end)
					_alloc.construct(buffer_end, value);
			}
			catch (...)
			{
				destroy_range(buffer, buffer_end);
				deallocate(buffer, count);
				throw;
			}

			size_type idx = iterator_index(pos);
			try
			{
				insert_buffer(idx, buffer, buffer_end);
			}
			catch (...)
			{
				destroy_range(buffer, buffer_end);
				deallocate(buffer, count);
				throw;
			}

			destroy_range(buffer, buffer_end);
			deallocate(buffer, count);
		}

		template <typename InputIt>
		void insert(iterator pos, InputIt first, InputIt last,
			typename ft::enable_if<!ft::is_integral<InputIt>::value>::type * = 0)
		{
			size_type idx = iterator_index(pos);
			typedef typename ft::iterator_traits<InputIt>::iterator_category category;
			insert_range(idx, first, last, category());
		}

		iterator erase(iterator pos)
		{
			if (pos == end())
				return pos;
			pointer erase_pos = pos;
			pointer next = erase_pos + 1;
			while (next != _end)
			{
				*erase_pos = *next;
				++erase_pos;
				++next;
			}
			--_end;
			_alloc.destroy(_end);
			return pos;
		}

		iterator erase(iterator first, iterator last)
		{
			if (first == last)
				return first;
			pointer dest = first;
			pointer src = last;
			while (src != _end)
			{
				*dest = *src;
				++dest;
				++src;
			}
			pointer new_end = dest;
			while (new_end != _end)
			{
				--_end;
				_alloc.destroy(_end);
			}
			_end = new_end;
			return first;
		}

		void swap(vector &other)
		{
			ft::swap(_alloc, other._alloc);
			ft::swap(_begin, other._begin);
			ft::swap(_end, other._end);
			ft::swap(_end_cap, other._end_cap);
		}

		void clear()
		{
			destroy_range(_begin, _end);
			_end = _begin;
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
