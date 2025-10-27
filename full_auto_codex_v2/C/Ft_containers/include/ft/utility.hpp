#pragma once

namespace ft
{
	template <typename T>
	void swap(T &lhs, T &rhs)
	{
		T tmp = lhs;
		lhs = rhs;
		rhs = tmp;
	}

	template <typename T1, typename T2>
	struct pair
	{
		typedef T1 first_type;
		typedef T2 second_type;

		first_type first;
		second_type second;

		pair() : first(), second()
		{
		}

		pair(const first_type &a, const second_type &b) : first(a), second(b)
		{
		}

		template <typename U, typename V>
		pair(const pair<U, V> &p) : first(p.first), second(p.second)
		{
		}

		pair &operator=(const pair &other)
		{
			if (this != &other)
			{
				first = other.first;
				second = other.second;
			}
			return *this;
		}
	};

	template <typename T1, typename T2>
	pair<T1, T2> make_pair(T1 x, T2 y)
	{
		return pair<T1, T2>(x, y);
	}

	template <typename T1, typename T2>
	bool operator==(const pair<T1, T2> &lhs, const pair<T1, T2> &rhs)
	{
		return lhs.first == rhs.first && lhs.second == rhs.second;
	}

	template <typename T1, typename T2>
	bool operator!=(const pair<T1, T2> &lhs, const pair<T1, T2> &rhs)
	{
		return !(lhs == rhs);
	}

	template <typename T1, typename T2>
	bool operator<(const pair<T1, T2> &lhs, const pair<T1, T2> &rhs)
	{
		return lhs.first < rhs.first
			|| (!(rhs.first < lhs.first) && lhs.second < rhs.second);
	}

	template <typename T1, typename T2>
	bool operator<=(const pair<T1, T2> &lhs, const pair<T1, T2> &rhs)
	{
		return !(rhs < lhs);
	}

	template <typename T1, typename T2>
	bool operator>(const pair<T1, T2> &lhs, const pair<T1, T2> &rhs)
	{
		return rhs < lhs;
	}

	template <typename T1, typename T2>
	bool operator>=(const pair<T1, T2> &lhs, const pair<T1, T2> &rhs)
	{
		return !(lhs < rhs);
	}
}
