#pragma once

#include "utility.hpp"
#include "vector.hpp"

namespace ft
{
	template <typename T, typename Container = ft::vector<T> >
	class stack
	{
	public:
		typedef T						  value_type;
		typedef Container				  container_type;
		typedef typename container_type::size_type size_type;

	protected:
		container_type c;

	public:
		explicit stack(const container_type &cont = container_type())
		: c(cont)
		{
		}

		bool empty() const
		{
			return c.empty();
		}

		size_type size() const
		{
			return c.size();
		}

		value_type &top()
		{
			return c.back();
		}

		const value_type &top() const
		{
			return c.back();
		}

		void push(const value_type &value)
		{
			c.push_back(value);
		}

		void pop()
		{
			c.pop_back();
		}

		friend bool operator==(const stack &lhs, const stack &rhs)
		{
			return lhs.c == rhs.c;
		}

		friend bool operator!=(const stack &lhs, const stack &rhs)
		{
			return !(lhs == rhs);
		}

		friend bool operator<(const stack &lhs, const stack &rhs)
		{
			return lhs.c < rhs.c;
		}

		friend bool operator<=(const stack &lhs, const stack &rhs)
		{
			return !(rhs < lhs);
		}

		friend bool operator>(const stack &lhs, const stack &rhs)
		{
			return rhs < lhs;
		}

		friend bool operator>=(const stack &lhs, const stack &rhs)
		{
			return !(lhs < rhs);
		}
	};
}
