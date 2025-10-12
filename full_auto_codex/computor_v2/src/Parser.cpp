#include "Parser.hpp"

#include <cmath>
#include <cstdlib>
#include <stdexcept>

Parser::Parser(const std::vector<Token> &tokens, std::map<std::string, Value> &env)
    : m_tokens(tokens), m_pos(0), m_env(env)
{
}

const Token &Parser::peek() const
{
    return m_tokens[m_pos];
}

const Token &Parser::consume()
{
    return m_tokens[m_pos++];
}

bool Parser::match(Token::Type type)
{
    if (peek().type == type)
    {
        consume();
        return true;
    }
    return false;
}

void Parser::expect(Token::Type type)
{
    if (!match(type))
        throw std::runtime_error("Unexpected token");
}

Value Parser::parse()
{
    Value value = parseExpression();
    if (peek().type != Token::END)
        throw std::runtime_error("Unexpected trailing tokens");
    return value;
}

Value Parser::parseExpression()
{
    Value value = parseTerm();
    while (true)
    {
        if (match(Token::PLUS))
            value = value + parseTerm();
        else if (match(Token::MINUS))
            value = value - parseTerm();
        else
            break;
    }
    return value;
}

Value Parser::parseTerm()
{
    Value value = parseFactor();
    while (true)
    {
        if (match(Token::MUL))
            value = value * parseFactor();
        else if (match(Token::DIV))
            value = value / parseFactor();
        else
            break;
    }
    return value;
}

Value Parser::parseFactor()
{
    if (match(Token::PLUS))
        return parseFactor();
    if (match(Token::MINUS))
    {
        Value val = parseFactor();
        if (val.getType() == Value::NUMBER)
            return Value(Complex(0.0) - val.getNumber());
        if (val.getType() == Value::MATRIX)
            return Value(val.getMatrix() * Complex(-1.0));
        throw std::runtime_error("Cannot negate value");
    }
    return parsePrimary();
}

Value Parser::parsePrimary()
{
    const Token &token = peek();
    if (token.type == Token::NUMBER)
    {
        consume();
        std::string text = token.text;
        bool imaginary = false;
        if (!text.empty() && (text[text.size() - 1] == 'i' || text[text.size() - 1] == 'I'))
        {
            imaginary = true;
            text = text.substr(0, text.size() - 1);
            if (text.empty())
                text = "1";
        }
        double value = ::strtod(text.c_str(), 0);
        if (imaginary)
            return Value(Complex(0.0, value));
        return Value(Complex(value));
    }
    if (token.type == Token::IDENT)
    {
        consume();
        std::string name = token.text;
        if (match(Token::LPAREN))
        {
            // function call
            Value result = parseFunctionCall(name);
            expect(Token::RPAREN);
            return result;
        }
        std::map<std::string, Value>::iterator it = m_env.find(name);
        if (it == m_env.end())
            throw std::runtime_error("Unknown identifier: " + name);
        return it->second;
    }
    if (match(Token::LPAREN))
    {
        Value inside = parseExpression();
        expect(Token::RPAREN);
        return inside;
    }
    if (match(Token::LBRACKET))
    {
        m_pos--; // revert to include '['
        return parseMatrix();
    }
    throw std::runtime_error("Unexpected token in expression");
}

Value Parser::parseMatrix()
{
    expect(Token::LBRACKET);
    std::vector<std::vector<Complex> > rows;
    while (true)
    {
        expect(Token::LBRACKET);
        std::vector<Complex> row;
        row.push_back(parseExpression().getNumber());
        while (match(Token::COMMA))
            row.push_back(parseExpression().getNumber());
        expect(Token::RBRACKET);
        rows.push_back(row);
        if (match(Token::SEMICOLON))
            continue;
        else
            break;
    }
    expect(Token::RBRACKET);
    return Value(Matrix(rows));
}

Value Parser::parseFunctionCall(const std::string &name)
{
    Value arg = parseExpression();
    if (name == "sin")
        return Value(::sin(arg.getNumber()));
    if (name == "cos")
        return Value(::cos(arg.getNumber()));
    if (name == "tan")
        return Value(::tan(arg.getNumber()));
    if (name == "exp")
        return Value(::exp(arg.getNumber()));
    if (name == "log")
        return Value(::log(arg.getNumber()));
    if (name == "sqrt")
        return Value(::sqrt(arg.getNumber()));
    throw std::runtime_error("Unknown function: " + name);
}
