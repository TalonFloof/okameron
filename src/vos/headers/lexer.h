#ifndef _VOS_LEXER_H
#define _VOS_LEXER_H 1

#include <stdint.h>
#include <stddef.h>

typedef enum {
    Comment,
    String,
    Integer,
    Float,
    Identifier,

    KeywordFunc,
    KeywordClass,
    KeywordEnum,
    KeywordImport,
    KeywordVar,
    KeywordPrivate,
    KeywordStatic,
    KeywordIf,
    KeywordElseif,
    KeywordElse,
    KeywordMatch,
    KeywordFor,
    KeywordBreak,
    KeywordContinue,
    KeywordReturn,
    KeywordTrue,
    KeywordFalse,
    KeywordSuper
} TokenType;

typedef struct {
	TokenType type;
	const char* start;
    int length;

    uint32_t line;
    uint32_t col;
} Token;

typedef struct {
    const char* filename;
    const char* buffer;
    const char* start;
    const char* pos;
    uint32_t line;
    uint32_t col;
    uint32_t length;

    Token* tokenVector;
    uint32_t tokenVecCapacity;
    uint32_t tokenVecLength;
} Lexer;

Lexer lexer_parse(const char* filename, const char* buffer);

#endif