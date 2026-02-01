/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Span.hpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef SPAN_HPP
# define SPAN_HPP

# include <vector>
# include <algorithm>
# include <exception>
# include <limits>

class Span
{
private:
	unsigned int		_maxSize;
	std::vector<int>	_data;

public:
	Span(void);
	Span(unsigned int n);
	Span(const Span& other);
	Span&	operator=(const Span& other);
	~Span(void);

	void	addNumber(int n);
	int		shortestSpan(void) const;
	int		longestSpan(void) const;

	template<typename Iterator>
	void addRange(Iterator begin, Iterator end) {
		while (begin != end) { addNumber(*begin); ++begin; }
	}

	class FullException : public std::exception {
	public: virtual const char* what() const throw() { return ("Span is full"); }
	};
	class NoSpanException : public std::exception {
	public: virtual const char* what() const throw() { return ("Not enough elements for span"); }
	};
};

#endif
