#include "turing.hpp"

#include <deque>
#include <iostream>
#include <stdexcept>

SimulationResult simulate(const Machine &m, const std::string &input, int max_steps, bool verbose)
{
	if (max_steps <= 0)
		max_steps = 10000;
	for (char c : input)
	{
		if (!m.alphabet.count(c) && c != m.blank)
			throw std::runtime_error(std::string("Input symbol not in alphabet: ") + c);
	}
	std::deque<char> tape(input.begin(), input.end());
	if (tape.empty())
		tape.push_back(m.blank);
	int head = 0;
	std::string state = m.initial_state;
	int steps = 0;
	while (steps < max_steps)
	{
		if (m.accept_states.count(state))
			break;
		char read = tape[head];
		auto sit = m.transitions.find(state);
		if (sit == m.transitions.end())
			break;
		auto tit = sit->second.find(read);
		if (tit == sit->second.end())
			break;
		const Transition &tr = tit->second;
		tape[head] = tr.write;
		if (verbose)
			std::cout << "[" << steps << "] " << state << " --" << read << "/" << tr.write << tr.move << "--> " << tr.next_state << " tape=";
		head += (tr.move == 'L' ? -1 : 1);
		if (head < 0)
		{
			tape.push_front(m.blank);
			head = 0;
		}
		if (head >= static_cast<int>(tape.size()))
			tape.push_back(m.blank);
		state = tr.next_state;
		if (verbose)
		{
			for (char c : tape)
				std::cout << c;
			std::cout << "\n ";
			for (int i = 0; i < head; ++i)
				std::cout << " ";
			std::cout << "^\n";
		}
		++steps;
	}
	std::string snapshot(tape.begin(), tape.end());
	bool accepted = m.accept_states.count(state) > 0;
	return SimulationResult{accepted, steps, state, snapshot};
}
