#include "Interpreter.hpp"
#include "Parser.hpp"
#include "Tokenizer.hpp"

#include <stdexcept>

Interpreter::Interpreter()
{
    m_env["i"] = Value(Complex(0.0, 1.0));
}

Value Interpreter::evaluate(const std::string &line, bool &isAssignment, std::string &assignedName)
{
    std::vector<Token> tokens = tokenize(line);
    size_t assignPos = tokens.size();
    for (size_t i = 0; i < tokens.size(); ++i)
    {
        if (tokens[i].type == Token::ASSIGN)
        {
            assignPos = i;
            break;
        }
    }

    if (assignPos < tokens.size())
    {
        if (assignPos == 0 || tokens[assignPos - 1].type != Token::IDENT)
            throw std::runtime_error("Invalid assignment");
        assignedName = tokens[assignPos - 1].text;
        std::vector<Token> rhsTokens;
        rhsTokens.insert(rhsTokens.end(), tokens.begin() + assignPos + 1, tokens.end());
        Parser parser(rhsTokens, m_env);
        Value value = parser.parse();
        m_env[assignedName] = value;
        isAssignment = true;
        return value;
    }
    else
    {
        Parser parser(tokens, m_env);
        isAssignment = false;
        return parser.parse();
    }
}
