#include <stddef.h>
#include <lexer.h>

static const char* keywords[] = {
    "func", "class", "enum", "import", "var", "private",
    "const", "if", "elseif", "else", "match", "for", "break", "continue", 
    "return", "true", "false", "super",
    "+", "-", "*", "/", "%", "==", "!=", "<=", ">=", "<<", ">>>", ">>",
    ":=", "=",
    "<", ">", "&&", "||", "!", "~", "^", "&", "|", "(", ")", "[", "]", "{", "}", NULL
};