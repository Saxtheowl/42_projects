#include <cctype>
#include <iostream>
#include <string>

static std::string toUpper(const std::string &input)
{
	std::string out = input;
	for (size_t i = 0; i < out.size(); ++i)
		out[i] = static_cast<char>(std::toupper(static_cast<unsigned char>(out[i])));
	return out;
}

int main(int argc, char **argv)
{
	if (argc == 1)
	{
		std::cout << "* LOUD AND UNBEARABLE FEEDBACK NOISE *" << std::endl;
		return 0;
	}

	for (int i = 1; i < argc; ++i)
		std::cout << toUpper(argv[i]);
	std::cout << std::endl;
	return 0;
}
