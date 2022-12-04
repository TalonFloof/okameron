#include <stdio.h>
#include <error.h>
#include <lexer.h>
#include <stdlib.h>
#include <string.h>

#define TOKEN_ALLOCATION_AMOUNT 128 /* Lowering this number will impact performance, but will improve memory usage. */

/*static const char* PatternComment = "\\/\\*.*?\\*\\/";
static const char* PatternString = "[\"]([^\"\\\\\\n]|\\\\.|\\\\\\n)*[\"]";
static const char* PatternIntBase10 = "[\\-0-9]+";
static const char* PatternIntBase2 = "0b[0-1]+";
static const char* PatternIntBase16 = "0x[0-9a-fA-F]+";
static const char* PatternIntFloat = "[0-9]+\\.[0-9]+";
static const char* PatternIdentifier = "[@_A-Za-z][\\._A-Za-z0-9]*";*/

/*
Keywords, sorted from smallest to largest:

if
var
for
func
enum
else
true
class
match
break
false
super
import
static
elseif
private
continue
*/

void lexer_add_token(Lexer* lex, TokenType type) {
    if(lex->tokenVecLength+1 > lex->tokenVecCapacity) {
        lex->tokenVector = (Token*)realloc(lex->tokenVector,(lex->tokenVecCapacity+TOKEN_ALLOCATION_AMOUNT)*sizeof(Token));
        lex->tokenVecCapacity += TOKEN_ALLOCATION_AMOUNT;
    }
    lex->tokenVector[lex->tokenVecLength++] = (Token){.type = type, .start = lex->start, .length = ((uintptr_t)(lex->pos))-((uintptr_t)(lex->start))};
    lex->start = lex->pos+1;
}

char lexer_peekChar(Lexer* lex) {
    return *lex->pos;
}

char lexer_peekNextChar(Lexer* lex) {
    if (lexer_peekChar(lex) == '\0') return '\0'; /* To keep us from looking past the end of the string */
      return *(lex->pos + 1);
}

char lexer_nextChar(Lexer* lex) {
    char c = lexer_peekChar(lex);
    lex->pos++;
    lex->colno++;
    return c;
}

void lexer_newline(Lexer* lex) {lex->pos++; lex->start++; lex->colno = 0; lex->lineno++;}

void lexer_scan_comment(Lexer* lex) {
    lex->pos+=2;
    lex->colno+=2;
    while(1) {
        char c = lexer_nextChar(lex);
        if(c=='\0') {err("%i:%i Comment extends beyond EOF", lex->lineno, lex->colno);}
        
    }
}

int lexer_next(Lexer* lex) {
    char c;
loop:
    c = lexer_peekChar(lex);

    if(c=='\0') {return 0;}
    if((c==' ')||(c=='\t')||(c=='\v')||(c=='\f')||(c=='\r')) {lex->pos++; lex->start++; if(c!='\r'){lex->colno++;} goto loop;}
    if(c=='\n') {lexer_newline(lex); goto loop;}

    err("%i:%i Unreconized Token", lex->lineno, lex->colno);
ret:
    return 1;
}

Lexer lexer_parse(const char* filename, const char* buffer) {
    /*results_t res = lexer(buffer,9+18,*/ /* Get ready for this long list... */
    /*    "Newline", "\n",
        "Comment", "\\/\\*.*?\\*\\/",
        "String", "[\"]([^\"\\\\\\n]|\\\\.|\\\\\\n)*[\"]",
        "Integer", "[\\-0-9]+",
        "Integer", "0x[0-9a-fA-F]+",
        "Integer", "0b[0-1]+",
        "Float", "[0-9]+\\.[0-9]+",
        "Identifier", "[@_A-Za-z][\\._A-Za-z0-9]*",
        "Symbol", "(\\+|-|\\*|\\/|%|~|\\^|\\(|\\)|\\[|\\]|\\{|\\}|\\,){1}|(=|!|<|>|:|&|\\|){1,2}",*/ /*9*/
/*
        "KeywordFunc", "func",
        "KeywordClass", "class",
        "KeywordEnum", "enum",
        "KeywordImport", "import",
        "KeywordVar", "var",
        "KeywordPrivate", "private",
        "KeywordStatic", "static",
        "KeywordIf", "if",
        "KeywordElseif", "elseif",
        "KeywordElse", "else",
        "KeywordMatch", "match",
        "KeywordFor", "for",
        "KeywordBreak", "break",
        "KeywordContinue", "continue",
        "KeywordReturn", "return",
        "KeywordTrue", "true",
        "KeywordFalse", "false",
        "KeywordSuper", "super"*/ /*18*/
    /*);*/
    Lexer lex;
    lex.filename = filename;
    lex.buffer = buffer;
    lex.start = buffer;
    lex.pos = buffer;
    lex.length = strlen(buffer);
    lex.tokenVector = (Token*)malloc(1);
    lex.tokenVecCapacity = 0;
    lex.tokenVecLength = 0;
    lex.lineno = 1;
    lex.colno = 0;
    while(lexer_next(&lex)) {};
    return lex;
}