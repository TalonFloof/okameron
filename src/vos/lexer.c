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

void lexer_add_token(Lexer* lex, Token token) {
    if(lex->tokenVecLength+1 > lex->tokenVecCapacity) {
        lex->tokenVector = (Token*)realloc(lex->tokenVector,(lex->tokenVecCapacity+TOKEN_ALLOCATION_AMOUNT)*sizeof(Token));
        lex->tokenVecCapacity += TOKEN_ALLOCATION_AMOUNT;
    }
    lex->tokenVector[lex->tokenVecLength++] = token;
}

int lexer_next(Lexer* lex) {
    
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
    lex.line = 1;
    lex.col = 0;
    lex.length = strlen(buffer);
    lex.tokenVector = (Token*)malloc(1);
    lex.tokenVecCapacity = 0;
    lex.tokenVecLength = 0;
    while(lexer_next(&lex)) {};
    return lex;
}