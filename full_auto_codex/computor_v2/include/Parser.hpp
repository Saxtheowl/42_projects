#ifndef PARSER_HPP
#define PARSER_HPP

#include "Tokenizer.hpp"
#include "Value.hpp"

#include <map>
#include <string>

class Parser
{
private:
    const std::vector<Token> &m_tokens;
    size_t                    m_pos;
    std::map<std::string, Value> &m_env;

    const Token &peek() const;
    const Token &consume();
    bool match(Token::Type type);
    void expect(Token::Type type);

    Value parseExpression();
    Value parseTerm();
    Value parseFactor();
    Value parsePrimary();

    Value parseMatrix();
    Value parseFunctionCall(const std::string &name);

public:
    Parser(const std::vector<Token> &tokens, std::map<std::string, Value> &env);
    Value parse();
};

#endif
