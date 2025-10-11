#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

static std::string replaceAll(const std::string &content, const std::string &from, const std::string &to)
{
    if (from.empty())
        return content;
    std::string result;
    size_t pos = 0;
    size_t found;
    while ((found = content.find(from, pos)) != std::string::npos)
    {
        result.append(content, pos, found - pos);
        result.append(to);
        pos = found + from.length();
    }
    result.append(content, pos, std::string::npos);
    return result;
}

int main(int argc, char **argv)
{
    if (argc != 4)
    {
        std::cerr << "Usage: " << argv[0] << " <filename> <s1> <s2>" << std::endl;
        return 1;
    }
    std::string filename(argv[1]);
    std::ifstream input(filename.c_str());
    if (!input)
    {
        std::cerr << "Error: cannot open input file" << std::endl;
        return 1;
    }
    std::ostringstream buffer;
    buffer << input.rdbuf();
    if (input.bad())
    {
        std::cerr << "Error reading file" << std::endl;
        return 1;
    }
    const std::string content = buffer.str();
    const std::string replaced = replaceAll(content, argv[2], argv[3]);

    std::ofstream output((filename + ".replace").c_str());
    if (!output)
    {
        std::cerr << "Error: cannot open output file" << std::endl;
        return 1;
    }
    output << replaced;
    if (!output)
    {
        std::cerr << "Error writing output file" << std::endl;
        return 1;
    }
    return 0;
}
