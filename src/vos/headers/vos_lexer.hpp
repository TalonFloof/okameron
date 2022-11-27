#pragma once

#include <string>
using std::string;

#include <memory>
using std::shared_ptr;

#include <vector>
using std::vector;

#include <unordered_map>
using std::unordered_map;

class Operators {
    
};

class Token {
public:
    enum TokenType {
        WHITESPACE,
        NEWLINE,
        IDENTIFIER,
        LITERAL,
        STRING,
        OPERATOR,
        LINE_COMMENT,
        BLOCK_COMMENT,
        UNKNOWN
    };
    Token(string text_, int line_, int charPos_, TokenType type) {
        text=text_;
        line=line_;
        charPos=charPos_;
        tokenType=type;
    }

    string getText() const {return text;}
    int getLine() const {return line;}
    int getCharPos() const {return charPos;}
    Token::TokenType getType() const {return tokenType;}
private:
    string text;
    int line;
    int charPos;
    TokenType tokenType;
};