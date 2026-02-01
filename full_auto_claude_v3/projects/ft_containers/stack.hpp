/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   stack.hpp                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef STACK_HPP
# define STACK_HPP

# include "vector.hpp"

namespace ft
{
	template <class T, class Container = ft::vector<T> >
	class stack
	{
	public:
		typedef T			value_type;
		typedef Container	container_type;
		typedef size_t		size_type;

	protected:
		container_type	c;

	public:
		explicit stack(const container_type& ctnr = container_type())
			: c(ctnr) {}

		stack(const stack& x) : c(x.c) {}

		~stack() {}

		stack& operator=(const stack& x)
		{
			c = x.c;
			return *this;
		}

		bool empty() const { return c.empty(); }
		size_type size() const { return c.size(); }

		value_type& top() { return c.back(); }
		const value_type& top() const { return c.back(); }

		void push(const value_type& val) { c.push_back(val); }
		void pop() { c.pop_back(); }

		template <class T1, class C1>
		friend bool operator==(const stack<T1, C1>& lhs, const stack<T1, C1>& rhs);

		template <class T1, class C1>
		friend bool operator<(const stack<T1, C1>& lhs, const stack<T1, C1>& rhs);
	};

	template <class T, class Container>
	bool operator==(const stack<T, Container>& lhs, const stack<T, Container>& rhs)
	{ return lhs.c == rhs.c; }

	template <class T, class Container>
	bool operator!=(const stack<T, Container>& lhs, const stack<T, Container>& rhs)
	{ return !(lhs == rhs); }

	template <class T, class Container>
	bool operator<(const stack<T, Container>& lhs, const stack<T, Container>& rhs)
	{ return lhs.c < rhs.c; }

	template <class T, class Container>
	bool operator<=(const stack<T, Container>& lhs, const stack<T, Container>& rhs)
	{ return !(rhs < lhs); }

	template <class T, class Container>
	bool operator>(const stack<T, Container>& lhs, const stack<T, Container>& rhs)
	{ return rhs < lhs; }

	template <class T, class Container>
	bool operator>=(const stack<T, Container>& lhs, const stack<T, Container>& rhs)
	{ return !(lhs < rhs); }
}

#endif
