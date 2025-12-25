#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

static std::string replaceAll(const std::string &input, const std::string &from, const std::string &to)
{
	if (from.empty())
		return input;
	std::string result;
	result.reserve(input.size());
	size_t pos = 0;
	while (true)
	{
		size_t found = input.find(from, pos);
		if (found == std::string::npos)
		{
			result.append(input.substr(pos));
			break;
		}
		result.append(input.substr(pos, found - pos));
		result.append(to);
		pos = found + from.size();
	}
	return result;
}

int main(int argc, char **argv)
{
	if (argc != 4)
	{
		std::cerr << "Usage: " << argv[0] << " <filename> <s1> <s2>" << std::endl;
		return 1;
	}

	std::string filename = argv[1];
	std::string s1 = argv[2];
	std::string s2 = argv[3];

	std::ifstream in(filename.c_str());
	if (!in.is_open())
	{
		std::cerr << "Error opening input file" << std::endl;
		return 1;
	}
	std::ostringstream buffer;
	buffer << in.rdbuf();
	std::string content = buffer.str();
	in.close();

	std::string replaced = replaceAll(content, s1, s2);
	std::string outName = filename + ".replace";
	std::ofstream out(outName.c_str());
	if (!out.is_open())
	{
		std::cerr << "Error opening output file" << std::endl;
		return 1;
	}
	out << replaced;
	return 0;
}
