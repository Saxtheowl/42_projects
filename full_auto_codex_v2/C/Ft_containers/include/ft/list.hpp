#pragma once

#include <cstddef>
#include <memory>
#include <stdexcept>
#include <functional>
#include "iterator.hpp"
#include "type_traits.hpp"
#include "algorithm.hpp"
#include "utility.hpp"

namespace ft
{
	struct list_node_base
	{
		list_node_base *prev;
		list_node_base *next;
	};

	template <typename T>
	struct list_node : list_node_base
	{
		T value;
	};

	template <typename T, typename Pointer, typename Reference>
	class list_iterator
	{
	public:
		typedef ft::bidirectional_iterator_tag iterator_category;
		typedef T							  value_type;
		typedef std::ptrdiff_t				  difference_type;
		typedef Pointer						  pointer;
		typedef Reference					  reference;
		typedef list_node<T>				  node;
		typedef list_node_base				  node_base;

	private:
		node_base *_node;

	public:
		list_iterator() : _node(NULL) {}
		explicit list_iterator(node_base *node) : _node(node) {}

		template <typename P, typename R>
		list_iterator(const list_iterator<T, P, R> &other) : _node(other.base())
		{
		}

		list_iterator &operator=(const list_iterator &other)
		{
			_node = other._node;
			return *this;
		}

		reference operator*() const
		{
			return static_cast<node *>(_node)->value;
		}

		pointer operator->() const
		{
			return &static_cast<node *>(_node)->value;
		}

		list_iterator &operator++()
		{
			_node = _node->next;
			return *this;
		}

		list_iterator operator++(int)
		{
			list_iterator tmp(*this);
			_node = _node->next;
			return tmp;
		}

		list_iterator &operator--()
		{
			_node = _node->prev;
			return *this;
		}

		list_iterator operator--(int)
		{
			list_iterator tmp(*this);
			_node = _node->prev;
			return tmp;
		}

		bool operator==(const list_iterator &other) const
		{
			return _node == other._node;
		}

		bool operator!=(const list_iterator &other) const
		{
			return _node != other._node;
		}

		node_base *base() const
		{
			return _node;
		}

		template <typename, typename, typename>
		friend class list_iterator;
	};

	template <typename T, typename Allocator = std::allocator<T> >
	class list
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

		typedef list_iterator<T, T *, T &>				  iterator;
		typedef list_iterator<T, const T *, const T &>	  const_iterator;
		typedef ft::reverse_iterator<iterator>			  reverse_iterator;
		typedef ft::reverse_iterator<const_iterator>	  const_reverse_iterator;

	private:
		typedef list_node<T> node;
		typedef list_node_base node_base;
		typedef typename allocator_type::template rebind<node>::other node_allocator_type;

		allocator_type	 _alloc;
		node_allocator_type _node_alloc;
		node_base		*_head;
		size_type		  _size;

		node_base *create_head()
		{
			node *head = _node_alloc.allocate(1);
			head->next = head;
			head->prev = head;
			return head;
		}

		void destroy_head()
		{
			_node_alloc.deallocate(static_cast<node *>(_head), 1);
		}

		node *create_node(const value_type &value)
		{
			node *n = _node_alloc.allocate(1);
			try
			{
				_alloc.construct(&n->value, value);
			}
			catch (...)
			{
				_node_alloc.deallocate(n, 1);
				throw;
			}
			return n;
		}

		void destroy_node(node *n)
		{
			_alloc.destroy(&n->value);
			_node_alloc.deallocate(n, 1);
		}

		void link_node(node_base *pos, node_base *new_node)
		{
			new_node->next = pos;
			new_node->prev = pos->prev;
			pos->prev->next = new_node;
			pos->prev = new_node;
			++_size;
		}

		void unlink_node(node_base *n)
		{
			n->prev->next = n->next;
			n->next->prev = n->prev;
			--_size;
		}

		size_type count_nodes(node_base *first, node_base *last) const
		{
			size_type n = 0;
			while (first != last)
			{
				first = first->next;
				++n;
			}
			return n;
		}

		void transfer(node_base *pos, node_base *first, node_base *last,
			size_type count, list *origin)
		{
			if (first == last)
				return;

			node_base *before_first = first->prev;
			node_base *last_prev = last->prev;
			node_base *before_pos = pos->prev;

			before_first->next = last;
			last->prev = before_first;

			before_pos->next = first;
			first->prev = before_pos;
			last_prev->next = pos;
			pos->prev = last_prev;

			if (this != origin)
			{
				_size += count;
				origin->_size -= count;
			}
		}

		template <typename Compare>
		void sort_impl(Compare comp)
		{
			if (_size < 2)
				return;

			list other(get_allocator());
			iterator mid = begin();
			for (size_type i = 0; i < _size / 2; ++i)
				++mid;
			other.splice(other.begin(), *this, mid, end());

			sort_impl(comp);
			other.sort_impl(comp);
			merge(other, comp);
		}

	public:
		explicit list(const allocator_type &alloc = allocator_type())
		: _alloc(alloc), _node_alloc(_alloc), _head(create_head()), _size(0)
		{
		}

		explicit list(size_type count, const value_type &value = value_type(),
			const allocator_type &alloc = allocator_type())
		: _alloc(alloc), _node_alloc(_alloc), _head(create_head()), _size(0)
		{
			insert(end(), count, value);
		}

		template <typename InputIt>
		list(InputIt first, InputIt last,
			const allocator_type &alloc = allocator_type(),
			typename ft::enable_if<!ft::is_integral<InputIt>::value>::type * = 0)
		: _alloc(alloc), _node_alloc(_alloc), _head(create_head()), _size(0)
		{
			insert(end(), first, last);
		}

		list(const list &other)
		: _alloc(other._alloc), _node_alloc(_alloc), _head(create_head()), _size(0)
		{
			insert(end(), other.begin(), other.end());
		}

		~list()
		{
			clear();
			destroy_head();
		}

		list &operator=(const list &other)
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
			return iterator(_head->next);
		}

		const_iterator begin() const
		{
			return const_iterator(_head->next);
		}

		iterator end()
		{
			return iterator(_head);
		}

		const_iterator end() const
		{
			return const_iterator(_head);
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

		bool empty() const
		{
			return _size == 0;
		}

		size_type size() const
		{
			return _size;
		}

		size_type max_size() const
		{
			return _node_alloc.max_size();
		}

		reference front()
		{
			return static_cast<node *>(_head->next)->value;
		}

		const_reference front() const
		{
			return static_cast<const node *>(_head->next)->value;
		}

		reference back()
		{
			return static_cast<node *>(_head->prev)->value;
		}

		const_reference back() const
		{
			return static_cast<const node *>(_head->prev)->value;
		}

		void assign(size_type count, const value_type &value)
		{
			clear();
			insert(end(), count, value);
		}

		template <typename InputIt>
		void assign(InputIt first, InputIt last,
			typename ft::enable_if<!ft::is_integral<InputIt>::value>::type * = 0)
		{
			clear();
			insert(end(), first, last);
		}

		void push_front(const value_type &value)
		{
			node *n = create_node(value);
			link_node(_head->next, n);
		}

		void pop_front()
		{
			if (empty())
				return;
			node_base *first = _head->next;
			unlink_node(first);
			destroy_node(static_cast<node *>(first));
		}

		void push_back(const value_type &value)
		{
			node *n = create_node(value);
			link_node(_head, n);
		}

		void pop_back()
		{
			if (empty())
				return;
			node_base *last = _head->prev;
			unlink_node(last);
			destroy_node(static_cast<node *>(last));
		}

		iterator insert(iterator pos, const value_type &value)
		{
			node *n = create_node(value);
			link_node(pos.base(), n);
			return iterator(n);
		}

		void insert(iterator pos, size_type count, const value_type &value)
		{
			for (size_type i = 0; i < count; ++i)
				insert(pos, value);
		}

		template <typename InputIt>
		void insert(iterator pos, InputIt first, InputIt last,
			typename ft::enable_if<!ft::is_integral<InputIt>::value>::type * = 0)
		{
			for (; first != last; ++first)
				insert(pos, *first);
		}

		iterator erase(iterator pos)
		{
			node_base *base = pos.base();
			node_base *next = base->next;
			unlink_node(base);
			destroy_node(static_cast<node *>(base));
			return iterator(next);
		}

		iterator erase(iterator first, iterator last)
		{
			while (first != last)
				first = erase(first);
			return last;
		}

		void swap(list &other)
		{
			ft::swap(_alloc, other._alloc);
			ft::swap(_node_alloc, other._node_alloc);
			ft::swap(_head, other._head);
			ft::swap(_size, other._size);
		}

		void resize(size_type count, value_type value = value_type())
		{
			while (_size > count)
				pop_back();
			while (_size < count)
				push_back(value);
		}

		void clear()
		{
			node_base *cur = _head->next;
			while (cur != _head)
			{
				node_base *next = cur->next;
				destroy_node(static_cast<node *>(cur));
				cur = next;
			}
			_head->next = _head;
			_head->prev = _head;
			_size = 0;
		}

		void splice(iterator pos, list &other)
		{
			if (&other == this || other.empty())
				return;
			size_type count = other._size;
			transfer(pos.base(), other._head->next, other._head, count, &other);
		}

		void splice(iterator pos, list &other, iterator it)
		{
			node_base *node_it = it.base();
			node_base *next = node_it->next;
			if (&other == this && (pos.base() == node_it || pos.base() == next))
				return;
			transfer(pos.base(), node_it, next, 1, &other);
		}

		void splice(iterator pos, list &other, iterator first, iterator last)
		{
			if (first == last)
				return;
			if (&other == this && pos == first)
				return;
			size_type count = other.count_nodes(first.base(), last.base());
			transfer(pos.base(), first.base(), last.base(), count, &other);
		}

		void remove(const value_type &value)
		{
			iterator it = begin();
			while (it != end())
			{
				if (*it == value)
					it = erase(it);
				else
					++it;
			}
		}

		template <typename Predicate>
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
			unique(std::equal_to<value_type>());
		}

		template <typename BinaryPredicate>
		void unique(BinaryPredicate pred)
		{
			if (_size < 2)
				return;
			iterator it = begin();
			iterator next = it;
			++next;
			while (next != end())
			{
				if (pred(*it, *next))
					next = erase(next);
				else
				{
					it = next;
					++next;
				}
			}
		}

		void merge(list &other)
		{
			merge(other, std::less<value_type>());
		}

		template <typename Compare>
		void merge(list &other, Compare comp)
		{
			if (&other == this || other.empty())
				return;

			iterator it = begin();
			iterator other_it = other.begin();
			while (it != end() && other_it != other.end())
			{
				if (comp(*other_it, *it))
				{
					iterator next_other = other_it;
					++next_other;
					transfer(it.base(), other_it.base(), next_other.base(), 1, &other);
					other_it = next_other;
				}
				else
					++it;
			}
			if (other_it != other.end())
			{
				size_type remaining = other.count_nodes(other_it.base(), other._head);
				transfer(end().base(), other_it.base(), other._head, remaining, &other);
			}
		}

		void sort()
		{
			sort(std::less<value_type>());
		}

		template <typename Compare>
		void sort(Compare comp)
		{
			sort_impl(comp);
		}

		void reverse()
		{
			if (_size < 2)
				return;
			node_base *current = _head;
			do
			{
				node_base *tmp = current->next;
				current->next = current->prev;
				current->prev = tmp;
				current = tmp;
			} while (current != _head);
		}
	};

	template <typename T, typename Alloc>
	bool operator==(const list<T, Alloc> &lhs, const list<T, Alloc> &rhs)
	{
		if (lhs.size() != rhs.size())
			return false;
		return ft::equal(lhs.begin(), lhs.end(), rhs.begin());
	}

	template <typename T, typename Alloc>
	bool operator!=(const list<T, Alloc> &lhs, const list<T, Alloc> &rhs)
	{
		return !(lhs == rhs);
	}

	template <typename T, typename Alloc>
	bool operator<(const list<T, Alloc> &lhs, const list<T, Alloc> &rhs)
	{
		return ft::lexicographical_compare(lhs.begin(), lhs.end(),
			rhs.begin(), rhs.end());
	}

	template <typename T, typename Alloc>
	bool operator<=(const list<T, Alloc> &lhs, const list<T, Alloc> &rhs)
	{
		return !(rhs < lhs);
	}

	template <typename T, typename Alloc>
	bool operator>(const list<T, Alloc> &lhs, const list<T, Alloc> &rhs)
	{
		return rhs < lhs;
	}

	template <typename T, typename Alloc>
	bool operator>=(const list<T, Alloc> &lhs, const list<T, Alloc> &rhs)
	{
		return !(lhs < rhs);
	}

	template <typename T, typename Alloc>
	void swap(list<T, Alloc> &lhs, list<T, Alloc> &rhs)
	{
		lhs.swap(rhs);
	}
}
