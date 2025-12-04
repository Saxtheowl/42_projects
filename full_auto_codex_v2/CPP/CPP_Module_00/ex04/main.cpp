#include <fstream>
#include <iostream>
#include <string>

static std::string replaceAll(const std::string &content, const std::string &s1, const std::string &s2)
{
	if (s1.empty())
		return content;
	std::string result;
	size_t pos = 0;
	while (true)
	{
		size_t found = content.find(s1, pos);
		if (found == std::string::npos)
		{
			result.append(content.substr(pos));
			break;
		}
		result.append(content.substr(pos, found - pos));
		result.append(s2);
		pos = found + s1.length();
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

	const std::string filename = argv[1];
	const std::string s1 = argv[2];
	const std::string s2 = argv[3];

	std::ifstream in(filename.c_str());
	if (!in)
	{
		std::cerr << "Error: cannot open input file" << std::endl;
		return 1;
	}

	std::string content((std::istreambuf_iterator<char>(in)), std::istreambuf_iterator<char>());
	in.close();

	std::string replaced = replaceAll(content, s1, s2);

	std::ofstream out((filename + ".replace").c_str());
	if (!out)
	{
		std::cerr << "Error: cannot open output file" << std::endl;
		return 1;
	}
	out << replaced;
	out.close();

	return 0;
}
