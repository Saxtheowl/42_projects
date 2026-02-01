/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.cpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Harl.hpp"

int	main(void)
{
	Harl	harl;

	std::cout << "=== DEBUG ===" << std::endl;
	harl.complain("DEBUG");

	std::cout << "\n=== INFO ===" << std::endl;
	harl.complain("INFO");

	std::cout << "\n=== WARNING ===" << std::endl;
	harl.complain("WARNING");

	std::cout << "\n=== ERROR ===" << std::endl;
	harl.complain("ERROR");

	std::cout << "\n=== UNKNOWN ===" << std::endl;
	harl.complain("UNKNOWN");

	return (0);
}
