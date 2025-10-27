#pragma once

namespace ft
{
	template <bool Cond, typename T = void>
	struct enable_if
	{
	};

	template <typename T>
	struct enable_if<true, T>
	{
		typedef T type;
	};

	template <typename T, T v>
	struct integral_constant
	{
		typedef T				 value_type;
		typedef integral_constant type;

		static const value_type	value = v;

		operator value_type() const
		{
			return value;
		}
	};

	typedef integral_constant<bool, true>	true_type;
	typedef integral_constant<bool, false>	false_type;

	template <typename T>
	struct remove_cv
	{
		typedef T type;
	};

	template <typename T>
	struct remove_cv<const T>
	{
		typedef T type;
	};

	template <typename T>
	struct remove_cv<volatile T>
	{
		typedef T type;
	};

	template <typename T>
	struct remove_cv<const volatile T>
	{
		typedef T type;
	};

	template <typename T>
	struct is_integral_helper : false_type
	{
	};

	template <>
	struct is_integral_helper<bool> : true_type
	{
	};

	template <>
	struct is_integral_helper<char> : true_type
	{
	};

	template <>
	struct is_integral_helper<signed char> : true_type
	{
	};

	template <>
	struct is_integral_helper<unsigned char> : true_type
	{
	};

	template <>
	struct is_integral_helper<wchar_t> : true_type
	{
	};

	template <>
	struct is_integral_helper<short> : true_type
	{
	};

	template <>
	struct is_integral_helper<unsigned short> : true_type
	{
	};

	template <>
	struct is_integral_helper<int> : true_type
	{
	};

	template <>
	struct is_integral_helper<unsigned int> : true_type
	{
	};

	template <>
	struct is_integral_helper<long> : true_type
	{
	};

	template <>
	struct is_integral_helper<unsigned long> : true_type
	{
	};

#ifdef __GNUC__
	template <>
	struct is_integral_helper<long long> : true_type
	{
	};

	template <>
	struct is_integral_helper<unsigned long long> : true_type
	{
	};
#endif

	template <typename T>
	struct is_integral : is_integral_helper<typename remove_cv<T>::type>
	{
	};
}
