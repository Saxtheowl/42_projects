/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   iter.hpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef ITER_HPP
# define ITER_HPP

# include <cstddef>

template<typename T>
void iter(T* array, size_t length, void (*f)(T&)) {
	for (size_t i = 0; i < length; i++) f(array[i]);
}

template<typename T>
void iter(T* array, size_t length, void (*f)(const T&)) {
	for (size_t i = 0; i < length; i++) f(array[i]);
}

#endif
