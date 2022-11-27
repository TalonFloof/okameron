#include <vos_lexer.hpp>

static const char* keywords[] = {
    "//", "/*", "*/",
    "func", "class", "enum", "import", "var", "private",
    "const", "if", "elseif", "else", "match", "for", "break", "continue", 
    "return", "true", "false", "super",
    "+", "-", "*", "/", "%", "==", "!=", "<=", ">=", "<<", ">>>", ">>",
    ":=", "=",
    "<", ">", "&&", "||", "~", "^", "&", "|", "(", ")", "[", "]", "{", "}", NULL
};

class Lexer {
public:
    enum Type {
        WHITESPACE,
        NEWLINE,
        IDENTIFIER,
        LETTER,
        DIGIT,
        OPERATOR,
        STRING,
        LINE_COMMENT,
        BLOCK_COMMENT,
        UNKNOWN
    };
private:
    void initialize();
	unordered_map<char, Type> hm;
};

Lexer lexer;

void Lexer::initialize() {
    hm[' ']=WHITESPACE;
	hm['\t']=WHITESPACE;
    hm['\r']=WHITESPACE; // Windows style line endings are ignored
    hm['\n']=NEWLINE;
    for (char c='a'; c<='z'; ++c)
		hm[c]=LETTER;
    for (char c='A'; c<='Z'; ++c)
		hm[c]=LETTER;
    hm['_']=LETTER;
    hm['@']=LETTER;
    hm['"']=STRING;
}

