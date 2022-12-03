#include <stdio.h>
#include <lexer.h>
#include <error.h>
#include <lex.h>
#include <tgc.h>

/*#define PEEK_CUR ((int)lexer->source[lexer->offset])
#define PEEK_NXT ((lexer->offset < lexer->length) ? lexer->source[lexer->offset+1] : 0)

static const char* keywords[] = {
    "func", "class", "enum", "include", "var", "private",
    "const", "if", "elseif", "else", "match", "for", "break", "continue", 
    "return", "true", "false", "super", NULL*/
    /*"+", "-", "*", "/", "%", "==", "!=", "<=", ">=", "<<", ">>>", ">>",
    ":=", "=",
    "<", ">", "&&", "||", "!", "~", "^", "&", "|", "(", ")", "[", "]", "{", "}", NULL*/
/*};

static bool is_alpha(int c) {
    if (c == '_') return true;
    if (c == '@') return true;
    return isalpha(c);
}

static bool is_string(int c) {
    return ((c == '"') || (c == '\''));
}

static bool is_identifier(int c) {
    return ((isalpha(c)) || (isdigit(c)) || (c == '_'));
}

static bool is_operator(int c) {
    return ((c == '+') || (c == '-') || (c == '*') || (c == '/') ||
            (c == '<') || (c == '>') || (c == '!') || (c == '=') ||
            (c == '|') || (c == '&') || (c == '^') || (c == '%') ||
            (c == '~') || (c == '.') || (c == ':') ||
            (c == ',') || (c == '{') || (c == '}') ||
            (c == '[') || (c == ']') || (c == '(') || (c == ')') );
}

static bool is_whitespace(int c) {
    return ((c == ' ') || (c == '\r') || (c == '\t') || (c == '\v') || (c == '\f'));
}

static bool is_comment(int c1, int c2) {
    return ((c1 == '/' && c2 == '*') || (c1 == '*' && c2 == '/'));
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

void lexer_scan_comment(Lexer* lexer) {

}

Token lexer_next(Lexer* lexer) {
    int c;
    Token token;

loop:
    c = PEEK_CUR;

    if(is_whitespace(c)) {lexer->offset++; lexer->position++; goto loop;}
    if(c == '\n') {lexer->offset++; lexer->position++; lexer->lineno++; lexer->colno = 0; goto loop;}*/
    /*if(is_comment(c,PEEK_NXT)) {lexer_scan_comment(lexer); goto return_token;}*/
/*    error("Unknown token at %i:%i\n", lexer->lineno, lexer->colno);
return_token:
    return token;
}*/

void lexer_parse(char* buffer) {
    results_t result = lexer(&vosGC,buffer,2, /* Get ready for this long list... */
        "Comment", "\\/\\*[\\s\\S]*?\\*\\/",
        "String", "\"(?:\\.|(\\\\\\\")|[^\\\"\"\\n])*\""
    );

}