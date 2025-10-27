#pragma once

#include <cstddef>

namespace ft
{
	struct input_iterator_tag {};
	struct output_iterator_tag {};
	struct forward_iterator_tag : input_iterator_tag {};
	struct bidirectional_iterator_tag : forward_iterator_tag {};
	struct random_access_iterator_tag : bidirectional_iterator_tag {};

	template <typename Category, typename T, typename Distance = std::ptrdiff_t,
		typename Pointer = T *, typename Reference = T &>
	struct iterator
	{
		typedef Category iterator_category;
		typedef T		 value_type;
		typedef Distance difference_type;
		typedef Pointer pointer;
		typedef Reference reference;
	};

	template <typename Iterator>
	struct iterator_traits
	{
		typedef typename Iterator::difference_type difference_type;
		typedef typename Iterator::value_type		 value_type;
		typedef typename Iterator::pointer		 pointer;
		typedef typename Iterator::reference	 reference;
		typedef typename Iterator::iterator_category iterator_category;
	};

	template <typename T>
	struct iterator_traits<T *>
	{
		typedef std::ptrdiff_t		 difference_type;
		typedef T			 value_type;
		typedef T *		 pointer;
		typedef T &		 reference;
		typedef random_access_iterator_tag iterator_category;
	};

	template <typename T>
	struct iterator_traits<const T *>
	{
		typedef std::ptrdiff_t		 difference_type;
		typedef T			 value_type;
		typedef const T *	 pointer;
		typedef const T & reference;
		typedef random_access_iterator_tag iterator_category;
	};

	template <typename Iter>
	class reverse_iterator
	{
	public:
		typedef Iter iterator_type;
		typedef typename iterator_traits<Iter>::iterator_category iterator_category;
		typedef typename iterator_traits<Iter>::value_type	 value_type;
		typedef typename iterator_traits<Iter>::difference_type difference_type;
		typedef typename iterator_traits<Iter>::pointer	 pointer;
		typedef typename iterator_traits<Iter>::reference reference;

	public:
		reverse_iterator() : current()
		{
		}

		explicit reverse_iterator(iterator_type it) : current(it)
		{
		}

		template <typename U>
		reverse_iterator(const reverse_iterator<U> &other) : current(other.base())
		{
		}

		iterator_type base() const
		{
			return current;
		}

		reference operator*() const
		{
			Iter tmp = current;
			--tmp;
			return *tmp;
		}

		pointer operator->() const
		{
			return &(**this);
		}

		reverse_iterator &operator++()
		{
			--current;
			return *this;
		}

		reverse_iterator operator++(int)
		{
			reverse_iterator tmp(*this);
			--current;
			return tmp;
		}

		reverse_iterator &operator--()
		{
			++current;
			return *this;
		}

		reverse_iterator operator--(int)
		{
			reverse_iterator tmp(*this);
			++current;
			return tmp;
		}

		reverse_iterator operator+(difference_type n) const
		{
			return reverse_iterator(current - n);
		}

		reverse_iterator &operator+=(difference_type n)
		{
			current -= n;
			return *this;
		}

		reverse_iterator operator-(difference_type n) const
		{
			return reverse_iterator(current + n);
		}

		reverse_iterator &operator-=(difference_type n)
		{
			current += n;
			return *this;
		}

		reference operator[](difference_type n) const
		{
			return *(*this + n);
		}

	private:
		Iter current;
	};

	template <typename Iterator1, typename Iterator2>
	bool operator==(const reverse_iterator<Iterator1> &lhs,
		const reverse_iterator<Iterator2> &rhs)
	{
		return lhs.base() == rhs.base();
	}

	template <typename Iterator1, typename Iterator2>
	bool operator!=(const reverse_iterator<Iterator1> &lhs,
		const reverse_iterator<Iterator2> &rhs)
	{
		return !(lhs == rhs);
	}

	template <typename Iterator1, typename Iterator2>
	bool operator<(const reverse_iterator<Iterator1> &lhs,
		const reverse_iterator<Iterator2> &rhs)
	{
		return lhs.base() > rhs.base();
	}

	template <typename Iterator1, typename Iterator2>
	bool operator<=(const reverse_iterator<Iterator1> &lhs,
		const reverse_iterator<Iterator2> &rhs)
	{
		return !(rhs < lhs);
	}

	template <typename Iterator1, typename Iterator2>
	bool operator>(const reverse_iterator<Iterator1> &lhs,
		const reverse_iterator<Iterator2> &rhs)
	{
		return rhs < lhs;
	}

	template <typename Iterator1, typename Iterator2>
	bool operator>=(const reverse_iterator<Iterator1> &lhs,
		const reverse_iterator<Iterator2> &rhs)
	{
		return !(lhs < rhs);
	}

	template <typename Iterator>
	reverse_iterator<Iterator> operator+(typename reverse_iterator<Iterator>::difference_type n,
		const reverse_iterator<Iterator> &it)
	{
		return reverse_iterator<Iterator>(it.base() - n);
	}

template <typename Iterator1, typename Iterator2>
typename reverse_iterator<Iterator1>::difference_type operator-(
	const reverse_iterator<Iterator1> &lhs,
	const reverse_iterator<Iterator2> &rhs)
{
	return rhs.base() - lhs.base();
}

template <typename InputIt>
typename iterator_traits<InputIt>::difference_type
distance(InputIt first, InputIt last)
{
	typename iterator_traits<InputIt>::difference_type count = 0;
	for (; first != last; ++first)
		++count;
	return count;
}

template <typename ForwardIt1, typename ForwardIt2>
void iter_swap(ForwardIt1 lhs, ForwardIt2 rhs)
{
	typename iterator_traits<ForwardIt1>::value_type tmp = *lhs;
	*lhs = *rhs;
	*rhs = tmp;
}
}
