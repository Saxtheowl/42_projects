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
#include <fstream>
#include <string>

std::string	replaceAll(std::string content, const std::string& s1, const std::string& s2)
{
	std::string	result;
	size_t		pos = 0;
	size_t		found;

	if (s1.empty())
		return (content);

	while ((found = content.find(s1, pos)) != std::string::npos)
	{
		result.append(content, pos, found - pos);
		result.append(s2);
		pos = found + s1.length();
	}
	result.append(content, pos, content.length() - pos);

	return (result);
}

int	main(int argc, char **argv)
{
	if (argc != 4)
	{
		std::cerr << "Usage: " << argv[0] << " <filename> <s1> <s2>" << std::endl;
		return (1);
	}

	std::string		filename = argv[1];
	std::string		s1 = argv[2];
	std::string		s2 = argv[3];
	std::ifstream	infile(filename.c_str());

	if (!infile.is_open())
	{
		std::cerr << "Error: could not open file " << filename << std::endl;
		return (1);
	}

	std::string		content;
	std::string		line;

	while (std::getline(infile, line))
	{
		content += line;
		if (!infile.eof())
			content += "\n";
	}
	infile.close();

	std::string		result = replaceAll(content, s1, s2);
	std::string		outfilename = filename + ".replace";
	std::ofstream	outfile(outfilename.c_str());

	if (!outfile.is_open())
	{
		std::cerr << "Error: could not create file " << outfilename << std::endl;
		return (1);
	}

	outfile << result;
	outfile.close();

	std::cout << "Replacement complete. Output written to " << outfilename << std::endl;

	return (0);
}
