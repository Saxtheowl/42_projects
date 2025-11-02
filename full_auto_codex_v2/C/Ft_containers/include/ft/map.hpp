#pragma once

#include <cstddef>
#include <memory>
#include <functional>
#include <stdexcept>
#include "iterator.hpp"
#include "type_traits.hpp"
#include "algorithm.hpp"
#include "utility.hpp"

namespace ft
{
	template <typename Key, typename T, typename Compare = std::less<Key>,
		typename Allocator = std::allocator< ft::pair<const Key, T> > >
	class map
	{
	public:
		typedef Key										  key_type;
		typedef T										  mapped_type;
        typedef ft::pair<const Key, T>					  value_type;
		typedef Compare									  key_compare;
		typedef Allocator								  allocator_type;
		typedef typename allocator_type::reference		  reference;
		typedef typename allocator_type::const_reference const_reference;
		typedef typename allocator_type::pointer		  pointer;
		typedef typename allocator_type::const_pointer	  const_pointer;
		typedef std::ptrdiff_t							  difference_type;
		typedef std::size_t								  size_type;

		class value_compare
		{
			friend class map;

		protected:
			key_compare _comp;
			explicit value_compare(key_compare c) : _comp(c) {}

		public:
			typedef bool result_type;
			typedef value_type first_argument_type;
			typedef value_type second_argument_type;

			bool operator()(const value_type &lhs, const value_type &rhs) const
			{
				return _comp(lhs.first, rhs.first);
			}
		};

	private:
		enum color_t
		{
			RED,
			BLACK
		};

		struct node
		{
			node	  *parent;
			node	  *left;
			node	  *right;
			color_t	color;
			value_type value;
		};

		typedef typename allocator_type::template rebind<node>::other node_allocator_type;

		allocator_type	 _alloc;
		node_allocator_type _node_alloc;
		key_compare		  _comp;
		node			  *_root;
		node			  *_nil;
		size_type		  _size;

		node *create_nil()
		{
			node *nil = _node_alloc.allocate(1);
			nil->parent = nil;
			nil->left = nil;
			nil->right = nil;
			nil->color = BLACK;
			_alloc.construct(&nil->value, value_type());
			return nil;
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
			n->parent = _nil;
			n->left = _nil;
			n->right = _nil;
			n->color = RED;
			return n;
		}

		void destroy_node(node *n)
		{
			_alloc.destroy(&n->value);
			_node_alloc.deallocate(n, 1);
		}

		void destroy_tree(node *n)
		{
			if (n == _nil)
				return;
			destroy_tree(n->left);
			destroy_tree(n->right);
			destroy_node(n);
		}

		node *minimum(node *n) const
		{
			if (n == _nil)
				return _nil;
			while (n->left != _nil)
				n = n->left;
			return n;
		}

		node *maximum(node *n) const
		{
			if (n == _nil)
				return _nil;
			while (n->right != _nil)
				n = n->right;
			return n;
		}

		node *successor(node *n) const
		{
			if (n == _nil)
				return minimum(_root);
			if (n->right != _nil)
				return minimum(n->right);
			node *p = n->parent;
			while (p != _nil && n == p->right)
			{
				n = p;
				p = p->parent;
			}
			return p;
		}

		node *predecessor(node *n) const
		{
			if (n == _nil)
				return maximum(_root);
			if (n->left != _nil)
				return maximum(n->left);
			node *p = n->parent;
			while (p != _nil && n == p->left)
			{
				n = p;
				p = p->parent;
			}
			return p;
		}

		void left_rotate(node *x)
		{
			node *y = x->right;
			x->right = y->left;
			if (y->left != _nil)
				y->left->parent = x;
			y->parent = x->parent;
			if (x->parent == _nil)
				_root = y;
			else if (x == x->parent->left)
				x->parent->left = y;
			else
				x->parent->right = y;
			y->left = x;
			x->parent = y;
		}

		void right_rotate(node *y)
		{
			node *x = y->left;
			y->left = x->right;
			if (x->right != _nil)
				x->right->parent = y;
			x->parent = y->parent;
			if (y->parent == _nil)
				_root = x;
			else if (y == y->parent->right)
				y->parent->right = x;
			else
				y->parent->left = x;
			x->right = y;
			y->parent = x;
		}

		void insert_fix(node *z)
		{
			while (z->parent->color == RED)
			{
				if (z->parent == z->parent->parent->left)
				{
					node *y = z->parent->parent->right;
					if (y->color == RED)
					{
						z->parent->color = BLACK;
						y->color = BLACK;
						z->parent->parent->color = RED;
						z = z->parent->parent;
					}
					else
					{
						if (z == z->parent->right)
						{
							z = z->parent;
							left_rotate(z);
						}
						z->parent->color = BLACK;
						z->parent->parent->color = RED;
						right_rotate(z->parent->parent);
					}
				}
				else
				{
					node *y = z->parent->parent->left;
					if (y->color == RED)
					{
						z->parent->color = BLACK;
						y->color = BLACK;
						z->parent->parent->color = RED;
						z = z->parent->parent;
					}
					else
					{
						if (z == z->parent->left)
						{
							z = z->parent;
							right_rotate(z);
						}
						z->parent->color = BLACK;
						z->parent->parent->color = RED;
						left_rotate(z->parent->parent);
					}
				}
			}
			_root->color = BLACK;
		}

		void transplant(node *u, node *v)
		{
			if (u->parent == _nil)
				_root = v;
			else if (u == u->parent->left)
				u->parent->left = v;
			else
				u->parent->right = v;
			v->parent = u->parent;
		}

		void erase_fix(node *x)
		{
			while (x != _root && x->color == BLACK)
			{
				if (x == x->parent->left)
				{
					node *w = x->parent->right;
					if (w->color == RED)
					{
						w->color = BLACK;
						x->parent->color = RED;
						left_rotate(x->parent);
						w = x->parent->right;
					}
					if (w->left->color == BLACK && w->right->color == BLACK)
					{
						w->color = RED;
						x = x->parent;
					}
					else
					{
						if (w->right->color == BLACK)
						{
							w->left->color = BLACK;
							w->color = RED;
							right_rotate(w);
							w = x->parent->right;
						}
						w->color = x->parent->color;
						x->parent->color = BLACK;
						w->right->color = BLACK;
						left_rotate(x->parent);
						x = _root;
					}
				}
				else
				{
					node *w = x->parent->left;
					if (w->color == RED)
					{
						w->color = BLACK;
						x->parent->color = RED;
						right_rotate(x->parent);
						w = x->parent->left;
					}
					if (w->right->color == BLACK && w->left->color == BLACK)
					{
						w->color = RED;
						x = x->parent;
					}
					else
					{
						if (w->left->color == BLACK)
						{
							w->right->color = BLACK;
							w->color = RED;
							left_rotate(w);
							w = x->parent->left;
						}
						w->color = x->parent->color;
						x->parent->color = BLACK;
						w->left->color = BLACK;
						right_rotate(x->parent);
						x = _root;
					}
				}
			}
			x->color = BLACK;
		}

		node *find_node(const key_type &key) const
		{
			node *current = _root;
			while (current != _nil)
			{
				if (_comp(key, current->value.first))
					current = current->left;
				else if (_comp(current->value.first, key))
					current = current->right;
				else
					return current;
			}
			return _nil;
		}

		node *lower_bound_node(const key_type &key) const
		{
			node *current = _root;
			node *result = _nil;
			while (current != _nil)
			{
				if (!_comp(current->value.first, key))
				{
					result = current;
					current = current->left;
				}
				else
					current = current->right;
			}
			return result;
		}

		node *upper_bound_node(const key_type &key) const
		{
			node *current = _root;
			node *result = _nil;
			while (current != _nil)
			{
				if (_comp(key, current->value.first))
				{
					result = current;
					current = current->left;
				}
				else
					current = current->right;
			}
			return result;
		}

		void erase_node(node *z)
		{
			node *y = z;
			node *x;
			color_t y_original_color = y->color;
			if (z->left == _nil)
			{
				x = z->right;
				transplant(z, z->right);
			}
			else if (z->right == _nil)
			{
				x = z->left;
				transplant(z, z->left);
			}
			else
			{
				y = minimum(z->right);
				y_original_color = y->color;
				x = y->right;
				if (y->parent == z)
					x->parent = y;
				else
				{
					transplant(y, y->right);
					y->right = z->right;
					y->right->parent = y;
				}
				transplant(z, y);
				y->left = z->left;
				y->left->parent = y;
				y->color = z->color;
			}
			destroy_node(z);
			--_size;
			if (y_original_color == BLACK)
				erase_fix(x);
		}

		void copy_from(const map &other)
		{
			for (const_iterator it = other.begin(); it != other.end(); ++it)
				insert(*it);
		}

	public:
		class iterator
		{
			node	   *_node;
			const map *_tree;

		public:
			typedef ft::bidirectional_iterator_tag iterator_category;
			typedef ft::pair<const Key, T>		  value_type;
			typedef std::ptrdiff_t				  difference_type;
			typedef value_type					* pointer;
			typedef value_type					& reference;

			iterator() : _node(NULL), _tree(NULL) {}
			iterator(node *n, const map *tree) : _node(n), _tree(tree) {}

			reference operator*() const
			{
				return _node->value;
			}

			pointer operator->() const
			{
				return &_node->value;
			}

			iterator &operator++()
			{
				_node = _tree->successor(_node);
				return *this;
			}

			iterator operator++(int)
			{
				iterator tmp(*this);
				++(*this);
				return tmp;
			}

			iterator &operator--()
			{
				if (_node == _tree->_nil)
					_node = _tree->maximum(_tree->_root);
				else
					_node = _tree->predecessor(_node);
				return *this;
			}

			iterator operator--(int)
			{
				iterator tmp(*this);
				--(*this);
				return tmp;
			}

			bool operator==(const iterator &other) const
			{
				return _node == other._node;
			}

			bool operator!=(const iterator &other) const
			{
				return _node != other._node;
			}

			node *base() const
			{
				return _node;
			}

			friend class map;
			friend class const_iterator;
		};

		class const_iterator
		{
			const node *_node;
			const map  *_tree;

		public:
			typedef ft::bidirectional_iterator_tag iterator_category;
			typedef ft::pair<const Key, T>		  value_type;
			typedef std::ptrdiff_t				  difference_type;
			typedef const value_type			  *pointer;
			typedef const value_type			  &reference;

			const_iterator() : _node(NULL), _tree(NULL) {}
			const_iterator(const node *n, const map *tree) : _node(n), _tree(tree) {}
			const_iterator(const iterator &other) : _node(other._node), _tree(other._tree) {}

			reference operator*() const
			{
				return _node->value;
			}

			pointer operator->() const
			{
				return &_node->value;
			}

			const_iterator &operator++()
			{
				_node = _tree->successor(const_cast<node *>(_node));
				return *this;
			}

			const_iterator operator++(int)
			{
				const_iterator tmp(*this);
				++(*this);
				return tmp;
			}

			const_iterator &operator--()
			{
				if (_node == _tree->_nil)
					_node = _tree->maximum(_tree->_root);
				else
					_node = _tree->predecessor(const_cast<node *>(_node));
				return *this;
			}

			const_iterator operator--(int)
			{
				const_iterator tmp(*this);
				--(*this);
				return tmp;
			}

			bool operator==(const const_iterator &other) const
			{
				return _node == other._node;
			}

			bool operator!=(const const_iterator &other) const
			{
				return _node != other._node;
			}

			const node *base() const
			{
				return _node;
			}

			friend class map;
		};

		typedef ft::reverse_iterator<iterator>		  reverse_iterator;
		typedef ft::reverse_iterator<const_iterator> const_reverse_iterator;

		explicit map(const key_compare &comp = key_compare(),
			const allocator_type &alloc = allocator_type())
		: _alloc(alloc), _node_alloc(_alloc), _comp(comp),
		  _root(NULL), _nil(create_nil()), _size(0)
		{
			_root = _nil;
		}

		template <typename InputIt>
		map(InputIt first, InputIt last, const key_compare &comp = key_compare(),
			const allocator_type &alloc = allocator_type(),
			typename ft::enable_if<!ft::is_integral<InputIt>::value>::type * = 0)
		: _alloc(alloc), _node_alloc(_alloc), _comp(comp),
		  _root(NULL), _nil(create_nil()), _size(0)
		{
			_root = _nil;
			insert(first, last);
		}

		map(const map &other)
		: _alloc(other._alloc), _node_alloc(_alloc), _comp(other._comp),
		  _root(NULL), _nil(create_nil()), _size(0)
		{
			_root = _nil;
			copy_from(other);
		}

		~map()
		{
			clear();
			destroy_node(_nil);
		}

		map &operator=(const map &other)
		{
			if (this != &other)
			{
				clear();
				_comp = other._comp;
				copy_from(other);
			}
			return *this;
		}

		allocator_type get_allocator() const
		{
			return _alloc;
		}

		iterator begin()
		{
			return iterator(minimum(_root), this);
		}

		const_iterator begin() const
		{
			return const_iterator(minimum(_root), this);
		}

		iterator end()
		{
			return iterator(_nil, this);
		}

		const_iterator end() const
		{
			return const_iterator(_nil, this);
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

		mapped_type &operator[](const key_type &key)
		{
			ft::pair<iterator, bool> res = insert(ft::make_pair(key, mapped_type()));
			return res.first->second;
		}

		void clear()
		{
			destroy_tree(_root);
			_root = _nil;
			_size = 0;
		}

		key_compare key_comp() const
		{
			return _comp;
		}

		value_compare value_comp() const
		{
			return value_compare(_comp);
		}

		ft::pair<iterator, bool> insert(const value_type &value)
		{
			node *parent = _nil;
			node *current = _root;
			while (current != _nil)
			{
				parent = current;
				if (_comp(value.first, current->value.first))
					current = current->left;
				else if (_comp(current->value.first, value.first))
					current = current->right;
				else
					return ft::pair<iterator, bool>(iterator(current, this), false);
			}
			node *n = create_node(value);
			n->parent = parent;
			if (parent == _nil)
				_root = n;
			else if (_comp(n->value.first, parent->value.first))
				parent->left = n;
			else
				parent->right = n;
			insert_fix(n);
			++_size;
			return ft::pair<iterator, bool>(iterator(n, this), true);
		}

		iterator insert(iterator hint, const value_type &value)
		{
			(void)hint;
			return insert(value).first;
		}

		template <typename InputIt>
		void insert(InputIt first, InputIt last,
			typename ft::enable_if<!ft::is_integral<InputIt>::value>::type * = 0)
		{
			for (; first != last; ++first)
				insert(*first);
		}

		void erase(iterator pos)
		{
			node *n = pos.base();
			if (n != _nil)
				erase_node(n);
		}

		size_type erase(const key_type &key)
		{
			node *n = find_node(key);
			if (n == _nil)
				return 0;
			erase_node(n);
			return 1;
		}

		void erase(iterator first, iterator last)
		{
			while (first != last)
			{
				iterator tmp = first;
				++first;
				erase(tmp);
			}
		}

		void swap(map &other)
		{
			ft::swap(_alloc, other._alloc);
			ft::swap(_node_alloc, other._node_alloc);
			ft::swap(_comp, other._comp);
			ft::swap(_root, other._root);
			ft::swap(_nil, other._nil);
			ft::swap(_size, other._size);
		}

		size_type count(const key_type &key) const
		{
			return find_node(key) != _nil;
		}

		iterator find(const key_type &key)
		{
			return iterator(find_node(key), this);
		}

		const_iterator find(const key_type &key) const
		{
			return const_iterator(find_node(key), this);
		}

		iterator lower_bound(const key_type &key)
		{
			return iterator(lower_bound_node(key), this);
		}

		const_iterator lower_bound(const key_type &key) const
		{
			return const_iterator(lower_bound_node(key), this);
		}

		iterator upper_bound(const key_type &key)
		{
			return iterator(upper_bound_node(key), this);
		}

		const_iterator upper_bound(const key_type &key) const
		{
			return const_iterator(upper_bound_node(key), this);
		}

		ft::pair<iterator, iterator> equal_range(const key_type &key)
		{
			return ft::make_pair(lower_bound(key), upper_bound(key));
		}

		ft::pair<const_iterator, const_iterator> equal_range(const key_type &key) const
		{
			return ft::make_pair(lower_bound(key), upper_bound(key));
		}
	};

	template <typename Key, typename T, typename Compare, typename Alloc>
	bool operator==(const map<Key, T, Compare, Alloc> &lhs,
		const map<Key, T, Compare, Alloc> &rhs)
	{
		if (lhs.size() != rhs.size())
			return false;
		return ft::equal(lhs.begin(), lhs.end(), rhs.begin());
	}

	template <typename Key, typename T, typename Compare, typename Alloc>
	bool operator!=(const map<Key, T, Compare, Alloc> &lhs,
		const map<Key, T, Compare, Alloc> &rhs)
	{
		return !(lhs == rhs);
	}

	template <typename Key, typename T, typename Compare, typename Alloc>
	bool operator<(const map<Key, T, Compare, Alloc> &lhs,
		const map<Key, T, Compare, Alloc> &rhs)
	{
		return ft::lexicographical_compare(lhs.begin(), lhs.end(),
			rhs.begin(), rhs.end());
	}

	template <typename Key, typename T, typename Compare, typename Alloc>
	bool operator<=(const map<Key, T, Compare, Alloc> &lhs,
		const map<Key, T, Compare, Alloc> &rhs)
	{
		return !(rhs < lhs);
	}

	template <typename Key, typename T, typename Compare, typename Alloc>
	bool operator>(const map<Key, T, Compare, Alloc> &lhs,
		const map<Key, T, Compare, Alloc> &rhs)
	{
		return rhs < lhs;
	}

	template <typename Key, typename T, typename Compare, typename Alloc>
	bool operator>=(const map<Key, T, Compare, Alloc> &lhs,
		const map<Key, T, Compare, Alloc> &rhs)
	{
		return !(lhs < rhs);
	}

	template <typename Key, typename T, typename Compare, typename Alloc>
	void swap(map<Key, T, Compare, Alloc> &lhs,
		map<Key, T, Compare, Alloc> &rhs)
	{
		lhs.swap(rhs);
	}
}
