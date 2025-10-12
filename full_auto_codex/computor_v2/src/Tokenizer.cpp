#include "Tokenizer.hpp"

#include <cctype>
#include <stdexcept>

std::vector<Token> tokenize(const std::string &line)
{
    std::vector<Token> tokens;
    size_t i = 0;
    while (i < line.size())
    {
        char c = line[i];
        if (std::isspace(static_cast<unsigned char>(c)))
        {
            ++i;
            continue;
        }
        if (std::isdigit(static_cast<unsigned char>(c)) || c == '.')
        {
            size_t start = i;
            while (i < line.size() && (std::isdigit(static_cast<unsigned char>(line[i])) || line[i] == '.'))
                ++i;
            if (i < line.size() && (line[i] == 'i' || line[i] == 'I'))
                ++i;
            tokens.push_back(Token(Token::NUMBER, line.substr(start, i - start)));
            continue;
        }
        if (std::isalpha(static_cast<unsigned char>(c)) || c == '_')
        {
            size_t start = i;
            while (i < line.size() && (std::isalnum(static_cast<unsigned char>(line[i])) || line[i] == '_'))
                ++i;
            tokens.push_back(Token(Token::IDENT, line.substr(start, i - start)));
            continue;
        }
        Token token;
        switch (c)
        {
        case '+': token = Token(Token::PLUS, "+"); break;
        case '-': token = Token(Token::MINUS, "-"); break;
        case '*': token = Token(Token::MUL, "*"); break;
        case '/': token = Token(Token::DIV, "/"); break;
        case '=': token = Token(Token::ASSIGN, "="); break;
        case '(': token = Token(Token::LPAREN, "("); break;
        case ')': token = Token(Token::RPAREN, ")"); break;
        case '[': token = Token(Token::LBRACKET, "["); break;
        case ']': token = Token(Token::RBRACKET, "]"); break;
        case ',': token = Token(Token::COMMA, ","); break;
        case ';': token = Token(Token::SEMICOLON, ";"); break;
        default:
            throw std::runtime_error("Unexpected character: " + std::string(1, c));
        }
        tokens.push_back(token);
        ++i;
    }
    tokens.push_back(Token(Token::END, ""));
    return tokens;
}
