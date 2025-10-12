#ifndef INTERPRETER_HPP
#define INTERPRETER_HPP

#include "Value.hpp"

#include <map>
#include <string>

class Interpreter
{
private:
    std::map<std::string, Value> m_env;

public:
    Interpreter();
    Value evaluate(const std::string &line, bool &isAssignment, std::string &assignedName);
};

#endif
