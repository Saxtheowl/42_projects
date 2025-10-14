/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.cpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <iostream>
#include "Point.hpp"

int main( void )
{
	// Triangle vertices
	Point a(0.0f, 0.0f);
	Point b(10.0f, 0.0f);
	Point c(5.0f, 10.0f);

	// Test points
	Point inside(5.0f, 5.0f);
	Point outside(15.0f, 5.0f);
	Point onVertex(0.0f, 0.0f);
	Point onEdge(5.0f, 0.0f);

	std::cout << "Triangle: A(0,0) B(10,0) C(5,10)" << std::endl;
	std::cout << std::endl;

	std::cout << "Point (5,5) is inside: " << (bsp(a, b, c, inside) ? "true" : "false") << std::endl;
	std::cout << "Point (15,5) is inside: " << (bsp(a, b, c, outside) ? "true" : "false") << std::endl;
	std::cout << "Point (0,0) [vertex] is inside: " << (bsp(a, b, c, onVertex) ? "true" : "false") << std::endl;
	std::cout << "Point (5,0) [edge] is inside: " << (bsp(a, b, c, onEdge) ? "true" : "false") << std::endl;

	return 0;
}
