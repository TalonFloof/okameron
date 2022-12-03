#ifndef _VOS_LEXER_H
#define _VOS_LEXER_H 1

#include <stdint.h>
#include <stddef.h>

typedef enum {
    COMMENT,
    STRING,
    NUMBER,
    IDENTIFIER,

    FUNC,
    CLASS,
    ENUM,
    IMPORT,
    VAR,
    PRIVATE,
    CONST,
    IF,
    ELSEIF,
    ELSE,
    MATCH,
    FOR,
    BREAK,
    CONTINUE,
    RETURN,
    TRUE,
    FALSE,
    SUPER,

    ADD,
    SUB,
    MUL,
    DIV,
    MOD,
    EQUALTO,
    NOT_EQUALTO,
    LESS_EQUAL,
    GREATER_EQUAL,
    LSHIFT,
    URSHIFT,
    RSHIFT,
    ASSIGN,
    EQUAL,
    LESS,
    MORE,
    AND,
    OR,
    NOT,
    BIN_NOT,
    BIN_XOR,
    BIN_AND,
    BIN_OR,
    LPARA,
    RPARA,
    LBRAKET,
    RBRAKET,
    LBRACE,
    RBRACE
} TokenType;

void lexer_parse(char* buffer);

#endif