#include "turing.hpp"

#include <fstream>
#include <sstream>
#include <stdexcept>
#include <vector>

static std::string trim(const std::string &s)
{
	size_t b = s.find_first_not_of(" \t\r\n");
	size_t e = s.find_last_not_of(" \t\r\n");
	if (b == std::string::npos)
		return "";
	return s.substr(b, e - b + 1);
}

static void parse_list(const std::string &line, std::set<std::string> &out)
{
	std::stringstream ss(line);
	std::string item;
	while (std::getline(ss, item, ','))
	{
		item = trim(item);
		if (!item.empty())
			out.insert(item);
	}
}

static void	validate_machine(const Machine &m)
{
	if (m.states.empty())
		throw std::runtime_error("No states defined");
	if (m.alphabet.empty())
		throw std::runtime_error("No alphabet defined");
	if (!m.blank_defined)
		throw std::runtime_error("Blank symbol not specified");
	if (m.initial_state.empty())
		throw std::runtime_error("No initial state defined");
	if (m.accept_states.empty())
		throw std::runtime_error("No accept states defined");
	if (!m.states.count(m.initial_state))
		throw std::runtime_error("Initial state not in states set");
	// Ensure blank symbol is part of the alphabet for validation downstream
	if (!m.alphabet.count(m.blank))
		throw std::runtime_error(std::string("Blank symbol '") + m.blank + "' not in alphabet");
	for (const auto &acc : m.accept_states)
		if (!m.states.count(acc))
			throw std::runtime_error("Accept state " + acc + " not in states set");
	for (const auto &st : m.transitions)
	{
		if (!m.states.count(st.first))
			throw std::runtime_error("Transition references unknown state: " + st.first);
		for (const auto &edge : st.second)
		{
			char read = edge.first;
			if (!m.alphabet.count(read) && read != m.blank)
				throw std::runtime_error("Transition reads symbol not in alphabet: " + std::string(1, read));
			const Transition &t = edge.second;
			if (!m.states.count(t.next_state))
				throw std::runtime_error("Transition targets unknown state: " + t.next_state);
			if (!m.alphabet.count(t.write) && t.write != m.blank)
				throw std::runtime_error("Transition writes symbol not in alphabet: " + std::string(1, t.write));
			if (t.move != 'L' && t.move != 'R')
				throw std::runtime_error("Transition move must be L or R");
		}
	}
}

Machine parse_machine(const std::string &path)
{
	Machine m;
	std::ifstream f(path);
	if (!f)
		throw std::runtime_error("Cannot open machine file: " + path);
	std::string line;
	int lineno = 0;
	while (std::getline(f, line))
	{
		++lineno;
		size_t hash = line.find('#');
		if (hash != std::string::npos)
			line = line.substr(0, hash);
		line = trim(line);
		if (line.empty())
			continue;
		if (line.rfind("states:", 0) == 0)
		{
			parse_list(trim(line.substr(7)), m.states);
			continue;
		}
		if (line.rfind("alphabet:", 0) == 0)
		{
			std::string rest = trim(line.substr(9));
			for (char c : rest)
			{
				if (c == ',' || c == ' ' || c == '\t')
					continue;
				m.alphabet.insert(c);
			}
			continue;
		}
		if (line.rfind("initial:", 0) == 0)
		{
			m.initial_state = trim(line.substr(8));
			continue;
		}
		if (line.rfind("accept:", 0) == 0)
		{
			parse_list(trim(line.substr(7)), m.accept_states);
			continue;
		}
		if (line.rfind("blank:", 0) == 0)
		{
			std::string rest = trim(line.substr(7));
			if (rest.empty())
				throw std::runtime_error("Line " + std::to_string(lineno) + ": blank symbol missing");
			if (rest.size() > 1)
				throw std::runtime_error("Line " + std::to_string(lineno) + ": blank symbol must be a single character");
			m.blank = rest[0];
			m.blank_defined = true;
			continue;
		}
		// transition: q0 a -> q1 b R
		std::stringstream ss(line);
		std::string cur, arrow, next;
		char read, write, move;
		if (!(ss >> cur >> read >> arrow >> next >> write >> move) || arrow != "->")
			throw std::runtime_error("Line " + std::to_string(lineno) + ": invalid transition format");
		std::string extra;
		if (ss >> extra)
			throw std::runtime_error("Line " + std::to_string(lineno) + ": extra tokens after transition");
		if (m.transitions[cur].count(read))
			throw std::runtime_error("Line " + std::to_string(lineno) + ": duplicate transition for state " + cur + " and symbol " + std::string(1, read));
		Transition t{next, write, move};
		m.transitions[cur][read] = t;
	}
	validate_machine(m);
	return m;
}

void validate_total_transitions(const Machine &m)
{
	for (const std::string &state : m.states)
	{
		if (m.accept_states.count(state))
			continue; // accept states may halt
		for (char sym : m.alphabet)
		{
			auto sit = m.transitions.find(state);
			if (sit == m.transitions.end() || sit->second.find(sym) == sit->second.end())
				throw std::runtime_error("Missing transition for state " + state + " and symbol " + std::string(1, sym));
		}
	}
}
