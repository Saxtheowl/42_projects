#pragma once

#include "utility.hpp"
#include "list.hpp"

namespace ft
{
	template <typename T, typename Container = ft::list<T> >
	class queue
	{
	public:
		typedef T						  value_type;
		typedef Container				  container_type;
		typedef typename container_type::size_type size_type;

	protected:
		container_type c;

	public:
		explicit queue(const container_type &cont = container_type())
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

		value_type &front()
		{
			return c.front();
		}

		const value_type &front() const
		{
			return c.front();
		}

		value_type &back()
		{
			return c.back();
		}

		const value_type &back() const
		{
			return c.back();
		}

		void push(const value_type &value)
		{
			c.push_back(value);
		}

		void pop()
		{
			c.pop_front();
		}

		friend bool operator==(const queue &lhs, const queue &rhs)
		{
			return lhs.c == rhs.c;
		}

		friend bool operator!=(const queue &lhs, const queue &rhs)
		{
			return !(lhs == rhs);
		}

		friend bool operator<(const queue &lhs, const queue &rhs)
		{
			return lhs.c < rhs.c;
		}

		friend bool operator<=(const queue &lhs, const queue &rhs)
		{
			return !(rhs < lhs);
		}

		friend bool operator>(const queue &lhs, const queue &rhs)
		{
			return rhs < lhs;
		}

		friend bool operator>=(const queue &lhs, const queue &rhs)
		{
			return !(lhs < rhs);
		}
	};
}
