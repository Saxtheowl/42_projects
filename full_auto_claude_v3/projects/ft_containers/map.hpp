/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   map.hpp                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef MAP_HPP
# define MAP_HPP

# include <memory>
# include <functional>
# include <stdexcept>
# include "iterator_traits.hpp"

namespace ft
{
	template <class T1, class T2>
	struct pair
	{
		typedef T1	first_type;
		typedef T2	second_type;

		T1	first;
		T2	second;

		pair() : first(), second() {}
		pair(const T1& a, const T2& b) : first(a), second(b) {}
		template <class U1, class U2>
		pair(const pair<U1, U2>& p) : first(p.first), second(p.second) {}
		pair& operator=(const pair& p)
		{
			first = p.first;
			second = p.second;
			return *this;
		}
	};

	template <class T1, class T2>
	pair<T1, T2> make_pair(T1 t, T2 u) { return pair<T1, T2>(t, u); }

	template <class T1, class T2>
	bool operator==(const pair<T1, T2>& x, const pair<T1, T2>& y)
	{ return x.first == y.first && x.second == y.second; }

	template <class T1, class T2>
	bool operator!=(const pair<T1, T2>& x, const pair<T1, T2>& y)
	{ return !(x == y); }

	template <class T1, class T2>
	bool operator<(const pair<T1, T2>& x, const pair<T1, T2>& y)
	{ return x.first < y.first || (!(y.first < x.first) && x.second < y.second); }

	template <class T1, class T2>
	bool operator<=(const pair<T1, T2>& x, const pair<T1, T2>& y)
	{ return !(y < x); }

	template <class T1, class T2>
	bool operator>(const pair<T1, T2>& x, const pair<T1, T2>& y)
	{ return y < x; }

	template <class T1, class T2>
	bool operator>=(const pair<T1, T2>& x, const pair<T1, T2>& y)
	{ return !(x < y); }

	enum rb_color { RED, BLACK };

	template <class T>
	struct rb_node
	{
		T			data;
		rb_node*	parent;
		rb_node*	left;
		rb_node*	right;
		rb_color	color;

		rb_node(const T& val = T())
			: data(val), parent(0), left(0), right(0), color(RED) {}
	};

	template <class T, class Node>
	class map_iterator
	{
	public:
		typedef T								value_type;
		typedef T&								reference;
		typedef T*								pointer;
		typedef ptrdiff_t						difference_type;
		typedef ft::bidirectional_iterator_tag	iterator_category;

	private:
		Node*	_node;
		Node*	_nil;

		Node* tree_min(Node* x) const
		{
			while (x->left != _nil)
				x = x->left;
			return x;
		}

		Node* tree_max(Node* x) const
		{
			while (x->right != _nil)
				x = x->right;
			return x;
		}

	public:
		map_iterator() : _node(0), _nil(0) {}
		map_iterator(Node* n, Node* nil) : _node(n), _nil(nil) {}
		map_iterator(const map_iterator& x) : _node(x._node), _nil(x._nil) {}

		map_iterator& operator=(const map_iterator& x)
		{
			_node = x._node;
			_nil = x._nil;
			return *this;
		}

		Node* base() const { return _node; }
		Node* nil() const { return _nil; }

		reference operator*() const { return _node->data; }
		pointer operator->() const { return &(_node->data); }

		map_iterator& operator++()
		{
			if (_node->right != _nil)
			{
				_node = tree_min(_node->right);
			}
			else
			{
				Node* p = _node->parent;
				while (p != _nil && _node == p->right)
				{
					_node = p;
					p = p->parent;
				}
				_node = p;
			}
			return *this;
		}

		map_iterator operator++(int)
		{
			map_iterator tmp(*this);
			++(*this);
			return tmp;
		}

		map_iterator& operator--()
		{
			if (_node == _nil)
			{
				_node = tree_max(_nil->parent);
			}
			else if (_node->left != _nil)
			{
				_node = tree_max(_node->left);
			}
			else
			{
				Node* p = _node->parent;
				while (p != _nil && _node == p->left)
				{
					_node = p;
					p = p->parent;
				}
				_node = p;
			}
			return *this;
		}

		map_iterator operator--(int)
		{
			map_iterator tmp(*this);
			--(*this);
			return tmp;
		}

		bool operator==(const map_iterator& x) const { return _node == x._node; }
		bool operator!=(const map_iterator& x) const { return _node != x._node; }
	};

	template <class T, class Node>
	class const_map_iterator
	{
	public:
		typedef T								value_type;
		typedef const T&						reference;
		typedef const T*						pointer;
		typedef ptrdiff_t						difference_type;
		typedef ft::bidirectional_iterator_tag	iterator_category;

	private:
		const Node*	_node;
		const Node*	_nil;

		const Node* tree_min(const Node* x) const
		{
			while (x->left != _nil)
				x = x->left;
			return x;
		}

		const Node* tree_max(const Node* x) const
		{
			while (x->right != _nil)
				x = x->right;
			return x;
		}

	public:
		const_map_iterator() : _node(0), _nil(0) {}
		const_map_iterator(const Node* n, const Node* nil) : _node(n), _nil(nil) {}
		const_map_iterator(const const_map_iterator& x) : _node(x._node), _nil(x._nil) {}
		const_map_iterator(const map_iterator<T, Node>& x) : _node(x.base()), _nil(x.nil()) {}

		const_map_iterator& operator=(const const_map_iterator& x)
		{
			_node = x._node;
			_nil = x._nil;
			return *this;
		}

		const Node* base() const { return _node; }
		const Node* nil() const { return _nil; }

		reference operator*() const { return _node->data; }
		pointer operator->() const { return &(_node->data); }

		const_map_iterator& operator++()
		{
			if (_node->right != _nil)
			{
				_node = tree_min(_node->right);
			}
			else
			{
				const Node* p = _node->parent;
				while (p != _nil && _node == p->right)
				{
					_node = p;
					p = p->parent;
				}
				_node = p;
			}
			return *this;
		}

		const_map_iterator operator++(int)
		{
			const_map_iterator tmp(*this);
			++(*this);
			return tmp;
		}

		const_map_iterator& operator--()
		{
			if (_node == _nil)
			{
				_node = tree_max(_nil->parent);
			}
			else if (_node->left != _nil)
			{
				_node = tree_max(_node->left);
			}
			else
			{
				const Node* p = _node->parent;
				while (p != _nil && _node == p->left)
				{
					_node = p;
					p = p->parent;
				}
				_node = p;
			}
			return *this;
		}

		const_map_iterator operator--(int)
		{
			const_map_iterator tmp(*this);
			--(*this);
			return tmp;
		}

		bool operator==(const const_map_iterator& x) const { return _node == x._node; }
		bool operator!=(const const_map_iterator& x) const { return _node != x._node; }
	};

	template <class Key, class T, class Compare = std::less<Key>,
			  class Allocator = std::allocator<pair<const Key, T> > >
	class map
	{
	public:
		typedef Key											key_type;
		typedef T											mapped_type;
		typedef pair<const Key, T>							value_type;
		typedef Compare										key_compare;
		typedef Allocator									allocator_type;
		typedef typename allocator_type::reference			reference;
		typedef typename allocator_type::const_reference	const_reference;
		typedef typename allocator_type::pointer			pointer;
		typedef typename allocator_type::const_pointer		const_pointer;
		typedef size_t										size_type;
		typedef ptrdiff_t									difference_type;

		class value_compare
		{
			friend class map;
		protected:
			Compare comp;
			value_compare(Compare c) : comp(c) {}
		public:
			bool operator()(const value_type& x, const value_type& y) const
			{ return comp(x.first, y.first); }
		};

	private:
		typedef rb_node<value_type>							node_type;
		typedef typename Allocator::template rebind<node_type>::other
															node_allocator;

		node_type*		_nil;
		node_type*		_root;
		size_type		_size;
		key_compare		_comp;
		node_allocator	_alloc;

		void init_nil()
		{
			_nil = _alloc.allocate(1);
			_alloc.construct(_nil, node_type());
			_nil->color = BLACK;
			_nil->parent = _nil;
			_nil->left = _nil;
			_nil->right = _nil;
			_root = _nil;
		}

		void rotate_left(node_type* x)
		{
			node_type* y = x->right;
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

		void rotate_right(node_type* x)
		{
			node_type* y = x->left;
			x->left = y->right;
			if (y->right != _nil)
				y->right->parent = x;
			y->parent = x->parent;
			if (x->parent == _nil)
				_root = y;
			else if (x == x->parent->right)
				x->parent->right = y;
			else
				x->parent->left = y;
			y->right = x;
			x->parent = y;
		}

		void insert_fixup(node_type* z)
		{
			while (z->parent->color == RED)
			{
				if (z->parent == z->parent->parent->left)
				{
					node_type* y = z->parent->parent->right;
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
							rotate_left(z);
						}
						z->parent->color = BLACK;
						z->parent->parent->color = RED;
						rotate_right(z->parent->parent);
					}
				}
				else
				{
					node_type* y = z->parent->parent->left;
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
							rotate_right(z);
						}
						z->parent->color = BLACK;
						z->parent->parent->color = RED;
						rotate_left(z->parent->parent);
					}
				}
			}
			_root->color = BLACK;
		}

		void transplant(node_type* u, node_type* v)
		{
			if (u->parent == _nil)
				_root = v;
			else if (u == u->parent->left)
				u->parent->left = v;
			else
				u->parent->right = v;
			v->parent = u->parent;
		}

		void delete_fixup(node_type* x)
		{
			while (x != _root && x->color == BLACK)
			{
				if (x == x->parent->left)
				{
					node_type* w = x->parent->right;
					if (w->color == RED)
					{
						w->color = BLACK;
						x->parent->color = RED;
						rotate_left(x->parent);
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
							rotate_right(w);
							w = x->parent->right;
						}
						w->color = x->parent->color;
						x->parent->color = BLACK;
						w->right->color = BLACK;
						rotate_left(x->parent);
						x = _root;
					}
				}
				else
				{
					node_type* w = x->parent->left;
					if (w->color == RED)
					{
						w->color = BLACK;
						x->parent->color = RED;
						rotate_right(x->parent);
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
							rotate_left(w);
							w = x->parent->left;
						}
						w->color = x->parent->color;
						x->parent->color = BLACK;
						w->left->color = BLACK;
						rotate_right(x->parent);
						x = _root;
					}
				}
			}
			x->color = BLACK;
		}

		node_type* tree_min(node_type* x) const
		{
			while (x->left != _nil)
				x = x->left;
			return x;
		}

		node_type* tree_max(node_type* x) const
		{
			while (x->right != _nil)
				x = x->right;
			return x;
		}

		void clear_tree(node_type* n)
		{
			if (n != _nil)
			{
				clear_tree(n->left);
				clear_tree(n->right);
				_alloc.destroy(n);
				_alloc.deallocate(n, 1);
			}
		}

		node_type* copy_tree(node_type* n, node_type* parent, node_type* other_nil)
		{
			if (n == other_nil)
				return _nil;
			node_type* new_node = _alloc.allocate(1);
			_alloc.construct(new_node, node_type(n->data));
			new_node->color = n->color;
			new_node->parent = parent;
			new_node->left = copy_tree(n->left, new_node, other_nil);
			new_node->right = copy_tree(n->right, new_node, other_nil);
			return new_node;
		}

	public:
		typedef map_iterator<value_type, node_type>				iterator;
		typedef const_map_iterator<value_type, node_type>		const_iterator;
		typedef ft::reverse_iterator<iterator>					reverse_iterator;
		typedef ft::reverse_iterator<const_iterator>			const_reverse_iterator;

		explicit map(const key_compare& comp = key_compare(),
					 const allocator_type& alloc = allocator_type())
			: _size(0), _comp(comp)
		{
			_alloc = node_allocator(alloc);
			init_nil();
		}

		template <class InputIterator>
		map(InputIterator first, InputIterator last,
			const key_compare& comp = key_compare(),
			const allocator_type& alloc = allocator_type())
			: _size(0), _comp(comp)
		{
			_alloc = node_allocator(alloc);
			init_nil();
			insert(first, last);
		}

		map(const map& x) : _size(0), _comp(x._comp), _alloc(x._alloc)
		{
			init_nil();
			*this = x;
		}

		~map()
		{
			clear();
			_alloc.destroy(_nil);
			_alloc.deallocate(_nil, 1);
		}

		map& operator=(const map& x)
		{
			if (this != &x)
			{
				clear();
				_comp = x._comp;
				if (x._root != x._nil)
					_root = copy_tree(x._root, _nil, x._nil);
				_size = x._size;
			}
			return *this;
		}

		iterator begin()
		{
			if (_root == _nil)
				return iterator(_nil, _nil);
			return iterator(tree_min(_root), _nil);
		}

		const_iterator begin() const
		{
			if (_root == _nil)
				return const_iterator(_nil, _nil);
			return const_iterator(tree_min(_root), _nil);
		}

		iterator end() { return iterator(_nil, _nil); }
		const_iterator end() const { return const_iterator(_nil, _nil); }

		reverse_iterator rbegin() { return reverse_iterator(end()); }
		const_reverse_iterator rbegin() const { return const_reverse_iterator(end()); }
		reverse_iterator rend() { return reverse_iterator(begin()); }
		const_reverse_iterator rend() const { return const_reverse_iterator(begin()); }

		bool empty() const { return _size == 0; }
		size_type size() const { return _size; }
		size_type max_size() const { return _alloc.max_size(); }

		mapped_type& operator[](const key_type& k)
		{
			iterator it = find(k);
			if (it == end())
				it = insert(value_type(k, mapped_type())).first;
			return it->second;
		}

		pair<iterator, bool> insert(const value_type& val)
		{
			node_type* y = _nil;
			node_type* x = _root;

			while (x != _nil)
			{
				y = x;
				if (_comp(val.first, x->data.first))
					x = x->left;
				else if (_comp(x->data.first, val.first))
					x = x->right;
				else
					return pair<iterator, bool>(iterator(x, _nil), false);
			}

			node_type* z = _alloc.allocate(1);
			_alloc.construct(z, node_type(val));
			z->parent = y;
			z->left = _nil;
			z->right = _nil;

			if (y == _nil)
				_root = z;
			else if (_comp(val.first, y->data.first))
				y->left = z;
			else
				y->right = z;

			_nil->parent = _root;
			++_size;
			insert_fixup(z);
			return pair<iterator, bool>(iterator(z, _nil), true);
		}

		iterator insert(iterator position, const value_type& val)
		{
			(void)position;
			return insert(val).first;
		}

		template <class InputIterator>
		void insert(InputIterator first, InputIterator last)
		{
			for (; first != last; ++first)
				insert(*first);
		}

		void erase(iterator position)
		{
			node_type* z = position.base();
			node_type* y = z;
			node_type* x;
			rb_color y_original_color = y->color;

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
				y = tree_min(z->right);
				y_original_color = y->color;
				x = y->right;
				if (y->parent == z)
				{
					x->parent = y;
				}
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

			_alloc.destroy(z);
			_alloc.deallocate(z, 1);
			--_size;
			_nil->parent = _root;

			if (y_original_color == BLACK)
				delete_fixup(x);
		}

		size_type erase(const key_type& k)
		{
			iterator it = find(k);
			if (it == end())
				return 0;
			erase(it);
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

		void swap(map& x)
		{
			node_type* tmp_nil = _nil;
			node_type* tmp_root = _root;
			size_type tmp_size = _size;
			key_compare tmp_comp = _comp;

			_nil = x._nil;
			_root = x._root;
			_size = x._size;
			_comp = x._comp;

			x._nil = tmp_nil;
			x._root = tmp_root;
			x._size = tmp_size;
			x._comp = tmp_comp;
		}

		void clear()
		{
			clear_tree(_root);
			_root = _nil;
			_nil->parent = _nil;
			_size = 0;
		}

		key_compare key_comp() const { return _comp; }
		value_compare value_comp() const { return value_compare(_comp); }

		iterator find(const key_type& k)
		{
			node_type* x = _root;
			while (x != _nil)
			{
				if (_comp(k, x->data.first))
					x = x->left;
				else if (_comp(x->data.first, k))
					x = x->right;
				else
					return iterator(x, _nil);
			}
			return end();
		}

		const_iterator find(const key_type& k) const
		{
			const node_type* x = _root;
			while (x != _nil)
			{
				if (_comp(k, x->data.first))
					x = x->left;
				else if (_comp(x->data.first, k))
					x = x->right;
				else
					return const_iterator(x, _nil);
			}
			return end();
		}

		size_type count(const key_type& k) const
		{
			return find(k) != end() ? 1 : 0;
		}

		iterator lower_bound(const key_type& k)
		{
			node_type* x = _root;
			node_type* result = _nil;
			while (x != _nil)
			{
				if (!_comp(x->data.first, k))
				{
					result = x;
					x = x->left;
				}
				else
					x = x->right;
			}
			return iterator(result, _nil);
		}

		const_iterator lower_bound(const key_type& k) const
		{
			const node_type* x = _root;
			const node_type* result = _nil;
			while (x != _nil)
			{
				if (!_comp(x->data.first, k))
				{
					result = x;
					x = x->left;
				}
				else
					x = x->right;
			}
			return const_iterator(result, _nil);
		}

		iterator upper_bound(const key_type& k)
		{
			node_type* x = _root;
			node_type* result = _nil;
			while (x != _nil)
			{
				if (_comp(k, x->data.first))
				{
					result = x;
					x = x->left;
				}
				else
					x = x->right;
			}
			return iterator(result, _nil);
		}

		const_iterator upper_bound(const key_type& k) const
		{
			const node_type* x = _root;
			const node_type* result = _nil;
			while (x != _nil)
			{
				if (_comp(k, x->data.first))
				{
					result = x;
					x = x->left;
				}
				else
					x = x->right;
			}
			return const_iterator(result, _nil);
		}

		pair<iterator, iterator> equal_range(const key_type& k)
		{
			return pair<iterator, iterator>(lower_bound(k), upper_bound(k));
		}

		pair<const_iterator, const_iterator> equal_range(const key_type& k) const
		{
			return pair<const_iterator, const_iterator>(lower_bound(k), upper_bound(k));
		}

		allocator_type get_allocator() const
		{
			return allocator_type(_alloc);
		}
	};

	template <class Key, class T, class Compare, class Alloc>
	bool operator==(const map<Key, T, Compare, Alloc>& lhs,
					const map<Key, T, Compare, Alloc>& rhs)
	{
		if (lhs.size() != rhs.size())
			return false;
		typename map<Key, T, Compare, Alloc>::const_iterator it1 = lhs.begin();
		typename map<Key, T, Compare, Alloc>::const_iterator it2 = rhs.begin();
		while (it1 != lhs.end())
		{
			if (*it1 != *it2)
				return false;
			++it1;
			++it2;
		}
		return true;
	}

	template <class Key, class T, class Compare, class Alloc>
	bool operator!=(const map<Key, T, Compare, Alloc>& lhs,
					const map<Key, T, Compare, Alloc>& rhs)
	{ return !(lhs == rhs); }

	template <class Key, class T, class Compare, class Alloc>
	bool operator<(const map<Key, T, Compare, Alloc>& lhs,
				   const map<Key, T, Compare, Alloc>& rhs)
	{
		typename map<Key, T, Compare, Alloc>::const_iterator it1 = lhs.begin();
		typename map<Key, T, Compare, Alloc>::const_iterator it2 = rhs.begin();
		while (it1 != lhs.end() && it2 != rhs.end())
		{
			if (*it1 < *it2) return true;
			if (*it2 < *it1) return false;
			++it1;
			++it2;
		}
		return it1 == lhs.end() && it2 != rhs.end();
	}

	template <class Key, class T, class Compare, class Alloc>
	bool operator<=(const map<Key, T, Compare, Alloc>& lhs,
					const map<Key, T, Compare, Alloc>& rhs)
	{ return !(rhs < lhs); }

	template <class Key, class T, class Compare, class Alloc>
	bool operator>(const map<Key, T, Compare, Alloc>& lhs,
				   const map<Key, T, Compare, Alloc>& rhs)
	{ return rhs < lhs; }

	template <class Key, class T, class Compare, class Alloc>
	bool operator>=(const map<Key, T, Compare, Alloc>& lhs,
					const map<Key, T, Compare, Alloc>& rhs)
	{ return !(lhs < rhs); }

	template <class Key, class T, class Compare, class Alloc>
	void swap(map<Key, T, Compare, Alloc>& x, map<Key, T, Compare, Alloc>& y)
	{ x.swap(y); }
}

#endif
