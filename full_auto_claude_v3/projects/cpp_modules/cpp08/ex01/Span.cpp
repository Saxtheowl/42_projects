/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Span.cpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Span.hpp"

Span::Span(void) : _maxSize(0) {}
Span::Span(unsigned int n) : _maxSize(n) {}
Span::Span(const Span& other) : _maxSize(other._maxSize), _data(other._data) {}
Span& Span::operator=(const Span& other) { if (this != &other) { _maxSize = other._maxSize; _data = other._data; } return (*this); }
Span::~Span(void) {}

void Span::addNumber(int n) {
	if (_data.size() >= _maxSize) throw FullException();
	_data.push_back(n);
}

int Span::shortestSpan(void) const {
	if (_data.size() < 2) throw NoSpanException();
	std::vector<int> sorted = _data;
	std::sort(sorted.begin(), sorted.end());
	int minSpan = std::numeric_limits<int>::max();
	for (size_t i = 1; i < sorted.size(); i++) {
		int span = sorted[i] - sorted[i - 1];
		if (span < minSpan) minSpan = span;
	}
	return (minSpan);
}

int Span::longestSpan(void) const {
	if (_data.size() < 2) throw NoSpanException();
	int min = *std::min_element(_data.begin(), _data.end());
	int max = *std::max_element(_data.begin(), _data.end());
	return (max - min);
}
