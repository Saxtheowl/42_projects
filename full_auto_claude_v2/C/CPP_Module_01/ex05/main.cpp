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

#include "Harl.hpp"
#include <iostream>

int	main(void)
{
	Harl	harl;

	std::cout << "=== DEBUG level ===" << std::endl;
	harl.complain("DEBUG");

	std::cout << "\n=== INFO level ===" << std::endl;
	harl.complain("INFO");

	std::cout << "\n=== WARNING level ===" << std::endl;
	harl.complain("WARNING");

	std::cout << "\n=== ERROR level ===" << std::endl;
	harl.complain("ERROR");

	std::cout << "\n=== Unknown level ===" << std::endl;
	harl.complain("UNKNOWN");

	return (0);
}
