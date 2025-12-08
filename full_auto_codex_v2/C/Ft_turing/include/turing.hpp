#pragma once

#include <map>
#include <set>
#include <string>
#include <vector>

struct Transition
{
	std::string next_state;
	char write;
	char move; // 'L' or 'R'
};

struct Machine
{
	std::set<std::string> states;
	std::set<char> alphabet;
	std::string initial_state;
	std::set<std::string> accept_states;
	char blank = 0;
	bool blank_defined = false;
	std::map<std::string, std::map<char, Transition>> transitions;
};

struct SimulationResult
{
	bool accepted;
	int steps;
	std::string final_state;
	std::string tape_snapshot;
};

Machine parse_machine(const std::string &path);
SimulationResult simulate(const Machine &m, const std::string &input, int max_steps, bool verbose);
