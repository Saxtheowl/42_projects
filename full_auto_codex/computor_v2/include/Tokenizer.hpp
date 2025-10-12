#ifndef TOKENIZER_HPP
#define TOKENIZER_HPP

#include <string>
#include <vector>

struct Token
{
    enum Type
    {
        NUMBER,
        IDENT,
        PLUS,
        MINUS,
        MUL,
        DIV,
        ASSIGN,
        LPAREN,
        RPAREN,
        LBRACKET,
        RBRACKET,
        COMMA,
        SEMICOLON,
        END
    } type;
    std::string text;

    Token(Type t = END, const std::string &value = std::string()) : type(t), text(value) {}
};

std::vector<Token> tokenize(const std::string &line);

#endif
