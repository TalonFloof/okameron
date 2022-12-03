#include <stddef.h>
#include <stdbool.h>
#include <lexer.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#define PEEK_NXT ((lexer->offset < lexer->length) ? lexer->source[lexer->offset+1] : 0)

static const char* keywords[] = {
    "func", "class", "enum", "import", "var", "private",
    "const", "if", "elseif", "else", "match", "for", "break", "continue", 
    "return", "true", "false", "super", NULL
    /*"+", "-", "*", "/", "%", "==", "!=", "<=", ">=", "<<", ">>>", ">>",
    ":=", "=",
    "<", ">", "&&", "||", "!", "~", "^", "&", "|", "(", ")", "[", "]", "{", "}", NULL*/
};

static bool is_alpha (int c) {
    if (c == '_') return true;
    if (c == '@') return true;
    return isalpha(c);
}

static bool is_string (int c) {
    return ((c == '"') || (c == '\''));
}

static bool is_identifier (int c) {
    return ((isalpha(c)) || (isdigit(c)) || (c == '_'));
}

static bool is_operator (int c) {
    return ((c == '+') || (c == '-') || (c == '*') || (c == '/') ||
            (c == '<') || (c == '>') || (c == '!') || (c == '=') ||
            (c == '|') || (c == '&') || (c == '^') || (c == '%') ||
            (c == '~') || (c == '.') || (c == ':') ||
            (c == ',') || (c == '{') || (c == '}') ||
            (c == '[') || (c == ']') || (c == '(') || (c == ')') );
}

static bool is_whitespace (int c) {
    return ((c == ' ') || (c == '\r') || (c == '\t') || (c == '\v') || (c == '\f'));
}

Lexer* lexer_create(const char *source, size_t len) {
    Lexer* lexer = malloc(sizeof(Lexer));
    if (!lexer) return NULL;
    memset(lexer,0,sizeof(Lexer));
    lexer->source = source;
    lexer->lineno = 1;
    lexer->colno = 0;
    lexer->length = len;
    lexer->offset = 0;
    lexer->position = 0;

    return lexer;
}

Token lexer_next(Lexer* lexer) {
    int c;
    Token token;

loop:
    c = PEEK_NXT;

    if (is_whitespace(c)) {lexer->offset++; lexer->position++; goto loop;}
    if (c == '\n') {lexer->offset++; lexer->position++; lexer->lineno++; lexer->colno = 0; goto loop;}
}