#pragma once

#include <functional>
#include <memory>
#include "iterator.hpp"
#include "type_traits.hpp"
#include "algorithm.hpp"
#include "utility.hpp"

namespace ft
{
	template <typename Key, typename T, typename Compare = std::less<Key>,
		typename Allocator = std::allocator< std::pair<const Key, T> > >
	class map
	{
	public:
		// TODO: ordered associative container implementation
	};
}
