#include "turing.hpp"

#include <iostream>
#include <stdexcept>

static void usage(const char *prog)
{
	std::cerr << "Usage: " << prog << " <machine_file> <input> [-v] [-t] [-s max_steps] [-c]\n";
	std::cerr << "  -c : vérifier que chaque état non-acceptant possède une transition pour chaque symbole de l'alphabet\n";
}

int main(int argc, char **argv)
{
	if (argc < 3)
	{
		usage(argv[0]);
		return 1;
	}
	std::string path = argv[1];
	std::string input = argv[2];
	bool verbose = false;
	bool show_tape = false;
	bool check_total = false;
	int max_steps = 10000;
	for (int i = 3; i < argc; ++i)
	{
		std::string arg = argv[i];
		if (arg == "-v")
			verbose = true;
		else if (arg == "-c")
			check_total = true;
		else if (arg == "-t")
			show_tape = true;
		else if (arg == "-s" && i + 1 < argc)
		{
			max_steps = std::stoi(argv[++i]);
		}
		else
		{
			usage(argv[0]);
			return 1;
		}
	}
	try
	{
		Machine m = parse_machine(path);
		if (check_total)
			validate_total_transitions(m);
		SimulationResult res = simulate(m, input, max_steps, verbose);
		std::cout << (res.accepted ? "ACCEPT" : "REJECT") << " after " << res.steps
				  << " steps (state=" << res.final_state << ")\n";
		if (verbose || show_tape)
			std::cout << "Final tape: " << res.tape_snapshot << "\n";
		return res.accepted ? 0 : 2;
	}
	catch (const std::exception &e)
	{
		std::cerr << "Error: " << e.what() << "\n";
		return 1;
	}
}
