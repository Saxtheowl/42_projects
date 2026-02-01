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

#include <iostream>
#include <string>
#include "vector.hpp"
#include "list.hpp"
#include "map.hpp"
#include "stack.hpp"
#include "queue.hpp"

void test_vector()
{
	std::cout << "=== VECTOR TESTS ===" << std::endl;

	ft::vector<int> v;
	std::cout << "Empty vector size: " << v.size() << std::endl;
	std::cout << "Empty: " << (v.empty() ? "true" : "false") << std::endl;

	for (int i = 1; i <= 5; ++i)
		v.push_back(i * 10);

	std::cout << "After push_back 10-50:" << std::endl;
	std::cout << "Size: " << v.size() << ", Capacity: " << v.capacity() << std::endl;
	std::cout << "Elements: ";
	for (size_t i = 0; i < v.size(); ++i)
		std::cout << v[i] << " ";
	std::cout << std::endl;

	std::cout << "Front: " << v.front() << ", Back: " << v.back() << std::endl;
	std::cout << "At(2): " << v.at(2) << std::endl;

	v.insert(v.begin() + 2, 25);
	std::cout << "After insert 25 at pos 2: ";
	for (ft::vector<int>::iterator it = v.begin(); it != v.end(); ++it)
		std::cout << *it << " ";
	std::cout << std::endl;

	v.erase(v.begin() + 1);
	std::cout << "After erase at pos 1: ";
	for (ft::vector<int>::iterator it = v.begin(); it != v.end(); ++it)
		std::cout << *it << " ";
	std::cout << std::endl;

	ft::vector<int> v2(3, 100);
	std::cout << "v2(3, 100): ";
	for (size_t i = 0; i < v2.size(); ++i)
		std::cout << v2[i] << " ";
	std::cout << std::endl;

	v.swap(v2);
	std::cout << "After swap, v: ";
	for (size_t i = 0; i < v.size(); ++i)
		std::cout << v[i] << " ";
	std::cout << std::endl;

	std::cout << "Reverse iterator: ";
	for (ft::vector<int>::reverse_iterator rit = v2.rbegin(); rit != v2.rend(); ++rit)
		std::cout << *rit << " ";
	std::cout << std::endl;

	std::cout << std::endl;
}

void test_list()
{
	std::cout << "=== LIST TESTS ===" << std::endl;

	ft::list<int> l;
	std::cout << "Empty list size: " << l.size() << std::endl;

	l.push_back(1);
	l.push_back(2);
	l.push_back(3);
	l.push_front(0);

	std::cout << "After push 0,1,2,3: ";
	for (ft::list<int>::iterator it = l.begin(); it != l.end(); ++it)
		std::cout << *it << " ";
	std::cout << std::endl;

	std::cout << "Front: " << l.front() << ", Back: " << l.back() << std::endl;

	l.pop_front();
	l.pop_back();
	std::cout << "After pop front and back: ";
	for (ft::list<int>::iterator it = l.begin(); it != l.end(); ++it)
		std::cout << *it << " ";
	std::cout << std::endl;

	ft::list<int> l2;
	l2.push_back(5);
	l2.push_back(3);
	l2.push_back(8);
	l2.push_back(1);

	std::cout << "l2 before sort: ";
	for (ft::list<int>::iterator it = l2.begin(); it != l2.end(); ++it)
		std::cout << *it << " ";
	std::cout << std::endl;

	l2.sort();
	std::cout << "l2 after sort: ";
	for (ft::list<int>::iterator it = l2.begin(); it != l2.end(); ++it)
		std::cout << *it << " ";
	std::cout << std::endl;

	l2.reverse();
	std::cout << "l2 after reverse: ";
	for (ft::list<int>::iterator it = l2.begin(); it != l2.end(); ++it)
		std::cout << *it << " ";
	std::cout << std::endl;

	ft::list<int> l3;
	l3.push_back(1);
	l3.push_back(1);
	l3.push_back(2);
	l3.push_back(2);
	l3.push_back(2);
	l3.push_back(3);
	std::cout << "l3 before unique: ";
	for (ft::list<int>::iterator it = l3.begin(); it != l3.end(); ++it)
		std::cout << *it << " ";
	std::cout << std::endl;

	l3.unique();
	std::cout << "l3 after unique: ";
	for (ft::list<int>::iterator it = l3.begin(); it != l3.end(); ++it)
		std::cout << *it << " ";
	std::cout << std::endl;

	std::cout << std::endl;
}

void test_map()
{
	std::cout << "=== MAP TESTS ===" << std::endl;

	ft::map<std::string, int> m;
	std::cout << "Empty map size: " << m.size() << std::endl;

	m["one"] = 1;
	m["two"] = 2;
	m["three"] = 3;
	m["four"] = 4;
	m["five"] = 5;

	std::cout << "After inserting one-five:" << std::endl;
	std::cout << "Size: " << m.size() << std::endl;
	std::cout << "Elements (sorted by key):" << std::endl;
	for (ft::map<std::string, int>::iterator it = m.begin(); it != m.end(); ++it)
		std::cout << "  " << it->first << " => " << it->second << std::endl;

	std::cout << "m[\"three\"] = " << m["three"] << std::endl;

	ft::map<std::string, int>::iterator found = m.find("two");
	if (found != m.end())
		std::cout << "Found 'two': " << found->second << std::endl;

	std::cout << "Count 'one': " << m.count("one") << std::endl;
	std::cout << "Count 'six': " << m.count("six") << std::endl;

	m.erase("two");
	std::cout << "After erase 'two', size: " << m.size() << std::endl;

	std::cout << "Lower bound 'four': " << m.lower_bound("four")->first << std::endl;
	std::cout << "Upper bound 'four': " << m.upper_bound("four")->first << std::endl;

	ft::map<int, std::string> m2;
	m2.insert(ft::make_pair(3, "three"));
	m2.insert(ft::make_pair(1, "one"));
	m2.insert(ft::make_pair(4, "four"));
	m2.insert(ft::make_pair(1, "duplicate"));
	m2.insert(ft::make_pair(2, "two"));

	std::cout << "m2 with integer keys:" << std::endl;
	for (ft::map<int, std::string>::iterator it = m2.begin(); it != m2.end(); ++it)
		std::cout << "  " << it->first << " => " << it->second << std::endl;

	std::cout << "Reverse iterator:" << std::endl;
	for (ft::map<int, std::string>::reverse_iterator rit = m2.rbegin(); rit != m2.rend(); ++rit)
		std::cout << "  " << rit->first << " => " << rit->second << std::endl;

	std::cout << std::endl;
}

void test_stack()
{
	std::cout << "=== STACK TESTS ===" << std::endl;

	ft::stack<int> s;
	std::cout << "Empty stack, empty: " << (s.empty() ? "true" : "false") << std::endl;

	s.push(10);
	s.push(20);
	s.push(30);

	std::cout << "After push 10, 20, 30:" << std::endl;
	std::cout << "Size: " << s.size() << std::endl;
	std::cout << "Top: " << s.top() << std::endl;

	s.pop();
	std::cout << "After pop, top: " << s.top() << std::endl;

	ft::stack<int> s2;
	s2.push(10);
	s2.push(20);

	std::cout << "s == s2: " << (s == s2 ? "true" : "false") << std::endl;
	std::cout << "s != s2: " << (s != s2 ? "true" : "false") << std::endl;

	std::cout << "Popping all elements: ";
	while (!s.empty())
	{
		std::cout << s.top() << " ";
		s.pop();
	}
	std::cout << std::endl;

	std::cout << std::endl;
}

void test_queue()
{
	std::cout << "=== QUEUE TESTS ===" << std::endl;

	ft::queue<int> q;
	std::cout << "Empty queue, empty: " << (q.empty() ? "true" : "false") << std::endl;

	q.push(10);
	q.push(20);
	q.push(30);

	std::cout << "After push 10, 20, 30:" << std::endl;
	std::cout << "Size: " << q.size() << std::endl;
	std::cout << "Front: " << q.front() << std::endl;
	std::cout << "Back: " << q.back() << std::endl;

	q.pop();
	std::cout << "After pop, front: " << q.front() << std::endl;

	ft::queue<int> q2;
	q2.push(20);
	q2.push(30);

	std::cout << "q == q2: " << (q == q2 ? "true" : "false") << std::endl;

	std::cout << "Dequeuing all elements: ";
	while (!q.empty())
	{
		std::cout << q.front() << " ";
		q.pop();
	}
	std::cout << std::endl;

	std::cout << std::endl;
}

void test_pair()
{
	std::cout << "=== PAIR TESTS ===" << std::endl;

	ft::pair<int, std::string> p1(1, "one");
	std::cout << "p1: (" << p1.first << ", " << p1.second << ")" << std::endl;

	ft::pair<int, std::string> p2 = ft::make_pair(2, std::string("two"));
	std::cout << "p2: (" << p2.first << ", " << p2.second << ")" << std::endl;

	ft::pair<int, std::string> p3 = p1;
	std::cout << "p3 (copy of p1): (" << p3.first << ", " << p3.second << ")" << std::endl;

	std::cout << "p1 == p3: " << (p1 == p3 ? "true" : "false") << std::endl;
	std::cout << "p1 < p2: " << (p1 < p2 ? "true" : "false") << std::endl;

	std::cout << std::endl;
}

int main()
{
	std::cout << "ft_containers - Testing all containers" << std::endl;
	std::cout << "=======================================" << std::endl << std::endl;

	test_pair();
	test_vector();
	test_list();
	test_map();
	test_stack();
	test_queue();

	std::cout << "All tests completed!" << std::endl;
	return 0;
}
