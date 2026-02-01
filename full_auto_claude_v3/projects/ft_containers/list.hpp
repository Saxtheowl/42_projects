/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   list.hpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef LIST_HPP
# define LIST_HPP

# include <memory>
# include "iterator_traits.hpp"

namespace ft
{
	template <class T>
	struct list_node
	{
		T			data;
		list_node	*prev;
		list_node	*next;
		list_node(const T& val = T()) : data(val), prev(0), next(0) {}
	};

	template <class T>
	class list_iterator
	{
	public:
		typedef T								value_type;
		typedef T&								reference;
		typedef T*								pointer;
		typedef ptrdiff_t						difference_type;
		typedef ft::bidirectional_iterator_tag	iterator_category;
		typedef list_node<T>*					node_pointer;

	private:
		node_pointer	_node;

	public:
		list_iterator() : _node(0) {}
		list_iterator(node_pointer n) : _node(n) {}
		list_iterator(const list_iterator& x) : _node(x._node) {}

		node_pointer base() const { return _node; }

		reference operator*() const { return _node->data; }
		pointer operator->() const { return &_node->data; }
		list_iterator& operator++() { _node = _node->next; return *this; }
		list_iterator operator++(int) { list_iterator tmp(*this); _node = _node->next; return tmp; }
		list_iterator& operator--() { _node = _node->prev; return *this; }
		list_iterator operator--(int) { list_iterator tmp(*this); _node = _node->prev; return tmp; }
		bool operator==(const list_iterator& x) const { return _node == x._node; }
		bool operator!=(const list_iterator& x) const { return _node != x._node; }
	};

	template <class T>
	class const_list_iterator
	{
	public:
		typedef T								value_type;
		typedef const T&						reference;
		typedef const T*						pointer;
		typedef ptrdiff_t						difference_type;
		typedef ft::bidirectional_iterator_tag	iterator_category;
		typedef const list_node<T>*				node_pointer;

	private:
		node_pointer	_node;

	public:
		const_list_iterator() : _node(0) {}
		const_list_iterator(node_pointer n) : _node(n) {}
		const_list_iterator(const list_iterator<T>& x) : _node(x.base()) {}

		node_pointer base() const { return _node; }

		reference operator*() const { return _node->data; }
		pointer operator->() const { return &_node->data; }
		const_list_iterator& operator++() { _node = _node->next; return *this; }
		const_list_iterator operator++(int) { const_list_iterator tmp(*this); _node = _node->next; return tmp; }
		const_list_iterator& operator--() { _node = _node->prev; return *this; }
		const_list_iterator operator--(int) { const_list_iterator tmp(*this); _node = _node->prev; return tmp; }
		bool operator==(const const_list_iterator& x) const { return _node == x._node; }
		bool operator!=(const const_list_iterator& x) const { return _node != x._node; }
	};

	template <class T, class Allocator = std::allocator<T> >
	class list
	{
	public:
		typedef T										value_type;
		typedef Allocator								allocator_type;
		typedef typename allocator_type::reference		reference;
		typedef typename allocator_type::const_reference	const_reference;
		typedef typename allocator_type::pointer		pointer;
		typedef typename allocator_type::const_pointer	const_pointer;
		typedef list_iterator<T>						iterator;
		typedef const_list_iterator<T>					const_iterator;
		typedef ft::reverse_iterator<iterator>			reverse_iterator;
		typedef ft::reverse_iterator<const_iterator>	const_reverse_iterator;
		typedef ptrdiff_t								difference_type;
		typedef size_t									size_type;

	private:
		typedef list_node<T>							node_type;
		typedef typename Allocator::template rebind<node_type>::other	node_allocator;

		node_type*		_end;
		size_type		_size;
		node_allocator	_alloc;

		node_type* create_node(const T& val = T())
		{
			node_type* node = _alloc.allocate(1);
			_alloc.construct(node, val);
			return node;
		}

		void destroy_node(node_type* node)
		{
			_alloc.destroy(node);
			_alloc.deallocate(node, 1);
		}

	public:
		explicit list(const allocator_type& alloc = allocator_type())
			: _size(0), _alloc(node_allocator())
		{
			(void)alloc;
			_end = create_node();
			_end->next = _end;
			_end->prev = _end;
		}

		explicit list(size_type n, const value_type& val = value_type(),
			const allocator_type& alloc = allocator_type())
			: _size(0), _alloc(node_allocator())
		{
			(void)alloc;
			_end = create_node();
			_end->next = _end;
			_end->prev = _end;
			assign(n, val);
		}

		template <class InputIterator>
		list(InputIterator first, InputIterator last,
			const allocator_type& alloc = allocator_type(),
			typename ft::enable_if<!ft::is_integral<InputIterator>::value>::type* = 0)
			: _size(0), _alloc(node_allocator())
		{
			(void)alloc;
			_end = create_node();
			_end->next = _end;
			_end->prev = _end;
			assign(first, last);
		}

		list(const list& x) : _size(0), _alloc(x._alloc)
		{
			_end = create_node();
			_end->next = _end;
			_end->prev = _end;
			*this = x;
		}

		~list()
		{
			clear();
			destroy_node(_end);
		}

		list& operator=(const list& x)
		{
			if (this != &x)
				assign(x.begin(), x.end());
			return *this;
		}

		iterator begin() { return iterator(_end->next); }
		const_iterator begin() const { return const_iterator(_end->next); }
		iterator end() { return iterator(_end); }
		const_iterator end() const { return const_iterator(_end); }
		reverse_iterator rbegin() { return reverse_iterator(end()); }
		const_reverse_iterator rbegin() const { return const_reverse_iterator(end()); }
		reverse_iterator rend() { return reverse_iterator(begin()); }
		const_reverse_iterator rend() const { return const_reverse_iterator(begin()); }

		bool empty() const { return _size == 0; }
		size_type size() const { return _size; }
		size_type max_size() const { return _alloc.max_size(); }

		reference front() { return _end->next->data; }
		const_reference front() const { return _end->next->data; }
		reference back() { return _end->prev->data; }
		const_reference back() const { return _end->prev->data; }

		template <class InputIterator>
		void assign(InputIterator first, InputIterator last,
			typename ft::enable_if<!ft::is_integral<InputIterator>::value>::type* = 0)
		{
			clear();
			for (; first != last; ++first)
				push_back(*first);
		}

		void assign(size_type n, const value_type& val)
		{
			clear();
			for (size_type i = 0; i < n; ++i)
				push_back(val);
		}

		void push_front(const value_type& val)
		{
			node_type* node = create_node(val);
			node->next = _end->next;
			node->prev = _end;
			_end->next->prev = node;
			_end->next = node;
			++_size;
		}

		void pop_front()
		{
			if (_size > 0)
			{
				node_type* node = _end->next;
				_end->next = node->next;
				node->next->prev = _end;
				destroy_node(node);
				--_size;
			}
		}

		void push_back(const value_type& val)
		{
			node_type* node = create_node(val);
			node->prev = _end->prev;
			node->next = _end;
			_end->prev->next = node;
			_end->prev = node;
			++_size;
		}

		void pop_back()
		{
			if (_size > 0)
			{
				node_type* node = _end->prev;
				_end->prev = node->prev;
				node->prev->next = _end;
				destroy_node(node);
				--_size;
			}
		}

		iterator insert(iterator position, const value_type& val)
		{
			node_type* pos = position.base();
			node_type* node = create_node(val);
			node->prev = pos->prev;
			node->next = pos;
			pos->prev->next = node;
			pos->prev = node;
			++_size;
			return iterator(node);
		}

		void insert(iterator position, size_type n, const value_type& val)
		{
			for (size_type i = 0; i < n; ++i)
				insert(position, val);
		}

		template <class InputIterator>
		void insert(iterator position, InputIterator first, InputIterator last,
			typename ft::enable_if<!ft::is_integral<InputIterator>::value>::type* = 0)
		{
			for (; first != last; ++first)
				insert(position, *first);
		}

		iterator erase(iterator position)
		{
			node_type* pos = position.base();
			node_type* next = pos->next;
			pos->prev->next = pos->next;
			pos->next->prev = pos->prev;
			destroy_node(pos);
			--_size;
			return iterator(next);
		}

		iterator erase(iterator first, iterator last)
		{
			while (first != last)
				first = erase(first);
			return last;
		}

		void swap(list& x)
		{
			node_type* tmp_end = _end;
			size_type tmp_size = _size;
			_end = x._end;
			_size = x._size;
			x._end = tmp_end;
			x._size = tmp_size;
		}

		void resize(size_type n, value_type val = value_type())
		{
			while (_size > n)
				pop_back();
			while (_size < n)
				push_back(val);
		}

		void clear()
		{
			while (_size > 0)
				pop_back();
		}

		void splice(iterator position, list& x)
		{
			splice(position, x, x.begin(), x.end());
		}

		void splice(iterator position, list& x, iterator i)
		{
			iterator next = i;
			++next;
			splice(position, x, i, next);
		}

		void splice(iterator position, list& x, iterator first, iterator last)
		{
			if (first == last)
				return;
			size_type count = 0;
			for (iterator it = first; it != last; ++it)
				++count;
			node_type* pos = position.base();
			node_type* first_node = first.base();
			node_type* last_node = last.base()->prev;
			first_node->prev->next = last.base();
			last.base()->prev = first_node->prev;
			first_node->prev = pos->prev;
			last_node->next = pos;
			pos->prev->next = first_node;
			pos->prev = last_node;
			_size += count;
			x._size -= count;
		}

		void remove(const value_type& val)
		{
			iterator it = begin();
			while (it != end())
			{
				if (*it == val)
					it = erase(it);
				else
					++it;
			}
		}

		template <class Predicate>
		void remove_if(Predicate pred)
		{
			iterator it = begin();
			while (it != end())
			{
				if (pred(*it))
					it = erase(it);
				else
					++it;
			}
		}

		void unique()
		{
			if (_size < 2)
				return;
			iterator it = begin();
			iterator next = it;
			++next;
			while (next != end())
			{
				if (*it == *next)
					next = erase(next);
				else
				{
					it = next;
					++next;
				}
			}
		}

		template <class BinaryPredicate>
		void unique(BinaryPredicate binary_pred)
		{
			if (_size < 2)
				return;
			iterator it = begin();
			iterator next = it;
			++next;
			while (next != end())
			{
				if (binary_pred(*it, *next))
					next = erase(next);
				else
				{
					it = next;
					++next;
				}
			}
		}

		void merge(list& x)
		{
			if (&x == this)
				return;
			iterator it1 = begin();
			iterator it2 = x.begin();
			while (it1 != end() && it2 != x.end())
			{
				if (*it2 < *it1)
				{
					iterator tmp = it2;
					++it2;
					splice(it1, x, tmp);
				}
				else
					++it1;
			}
			if (it2 != x.end())
				splice(end(), x, it2, x.end());
		}

		template <class Compare>
		void merge(list& x, Compare comp)
		{
			if (&x == this)
				return;
			iterator it1 = begin();
			iterator it2 = x.begin();
			while (it1 != end() && it2 != x.end())
			{
				if (comp(*it2, *it1))
				{
					iterator tmp = it2;
					++it2;
					splice(it1, x, tmp);
				}
				else
					++it1;
			}
			if (it2 != x.end())
				splice(end(), x, it2, x.end());
		}

		void sort()
		{
			if (_size < 2)
				return;
			for (iterator it = begin(); it != end(); ++it)
			{
				iterator min = it;
				for (iterator jt = it; jt != end(); ++jt)
					if (*jt < *min)
						min = jt;
				if (min != it)
				{
					T tmp = *it;
					*it = *min;
					*min = tmp;
				}
			}
		}

		template <class Compare>
		void sort(Compare comp)
		{
			if (_size < 2)
				return;
			for (iterator it = begin(); it != end(); ++it)
			{
				iterator min = it;
				for (iterator jt = it; jt != end(); ++jt)
					if (comp(*jt, *min))
						min = jt;
				if (min != it)
				{
					T tmp = *it;
					*it = *min;
					*min = tmp;
				}
			}
		}

		void reverse()
		{
			if (_size < 2)
				return;
			node_type* current = _end;
			do
			{
				node_type* tmp = current->next;
				current->next = current->prev;
				current->prev = tmp;
				current = tmp;
			} while (current != _end);
		}
	};

	template <class T, class Alloc>
	bool operator==(const list<T, Alloc>& lhs, const list<T, Alloc>& rhs)
	{
		if (lhs.size() != rhs.size())
			return false;
		typename list<T, Alloc>::const_iterator it1 = lhs.begin();
		typename list<T, Alloc>::const_iterator it2 = rhs.begin();
		while (it1 != lhs.end())
		{
			if (*it1 != *it2)
				return false;
			++it1;
			++it2;
		}
		return true;
	}

	template <class T, class Alloc>
	bool operator!=(const list<T, Alloc>& lhs, const list<T, Alloc>& rhs)
	{ return !(lhs == rhs); }

	template <class T, class Alloc>
	bool operator<(const list<T, Alloc>& lhs, const list<T, Alloc>& rhs)
	{
		typename list<T, Alloc>::const_iterator it1 = lhs.begin();
		typename list<T, Alloc>::const_iterator it2 = rhs.begin();
		while (it1 != lhs.end() && it2 != rhs.end())
		{
			if (*it1 < *it2) return true;
			if (*it2 < *it1) return false;
			++it1;
			++it2;
		}
		return it1 == lhs.end() && it2 != rhs.end();
	}

	template <class T, class Alloc>
	bool operator<=(const list<T, Alloc>& lhs, const list<T, Alloc>& rhs)
	{ return !(rhs < lhs); }

	template <class T, class Alloc>
	bool operator>(const list<T, Alloc>& lhs, const list<T, Alloc>& rhs)
	{ return rhs < lhs; }

	template <class T, class Alloc>
	bool operator>=(const list<T, Alloc>& lhs, const list<T, Alloc>& rhs)
	{ return !(lhs < rhs); }

	template <class T, class Alloc>
	void swap(list<T, Alloc>& x, list<T, Alloc>& y)
	{ x.swap(y); }
}

#endif
