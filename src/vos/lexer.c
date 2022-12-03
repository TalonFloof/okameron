#include <stdio.h>
#include <error.h>
#include <lex.h>

static const char* PatternComment = "\\/\\*.*?\\*\\/";
static const char* PatternString = "[\"]([^\"\\\\\\n]|\\\\.|\\\\\\n)*[\"]";
static const char* PatternIntBase10 = "[\\-0-9]+";
static const char* PatternIntBase2 = "0b[0-1]+";
static const char* PatternIntBase16 = "0x[0-9a-fA-F]+";
static const char* PatternIntFloat = "[0-9]+\\.[0-9]+";
static const char* PatternIdentifier = "[@_A-Za-z][\\._A-Za-z0-9]*";

static const char* keywords = {
    "func", "class", "enum", "import", "var", "private", "static",
    "if","elseif", "else", "match", "for", "break", "continue", "return", "true", "false", "super", NULL
};

results_t lexer_parse(char* buffer) {
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
    /*int i;
    for(i = 0 ; i < res.ntoks ; i++ ){
		printf("TYPE : %s | TEXT : %s\n",res.toks[i].type, res.toks[i].str);
	}*/
    /*return res;*/
}