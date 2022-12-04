#include <lexer.h>
#include <vos.h>
#include <utf8.h>
#include <vos_ctype.h>

#define err ((VosDelegate*)(lex->delegate))->error_handler

utf8_int32_t lexer_peekChar(Lexer* lex) {
    utf8_int32_t c;
    utf8codepoint(lex->pos, &c);
    return c;
}

utf8_int32_t lexer_peekNextChar(Lexer* lex) {
    if ((*lex->pos) == '\0') return '\0'; /* To keep us from looking past the end of the string */
    utf8_int32_t c;
    utf8codepoint(lex->pos+1, &c);
    return c;
}

utf8_int32_t lexer_nextChar(Lexer* lex) {
    utf8_int32_t c;
    lex->pos = (const char*)utf8codepoint(lex->pos, &c);
    lex->colno++;
    return c;
}

void lexer_newline(Lexer* lex) {lex->pos++; lex->start++; lex->colno = 0; lex->lineno++;}

Token lexer_add_token(Lexer* lex, TokenType type) {
    Token tok = (Token){.type = type, .start = lex->start, .length = ((uintptr_t)(lex->pos))-((uintptr_t)(lex->start))};
    lex->start = lex->pos;
    return tok;
}

void lexer_scan_comment(Lexer* lex) {
    lex->pos+=2;
    lex->colno+=2;
    while(1) {
        utf8_int32_t c = lexer_peekChar(lex);
        utf8_int32_t c2 = lexer_peekNextChar(lex);
        if(c=='\0') {err("%s %i:%i Comment extends beyond EOF", lex->filename, lex->lineno, lex->colno);}
        if((c == '*') && (c2 == '/')) {lexer_nextChar(lex); lexer_nextChar(lex); lex->start = lex->pos; break;}
        if(c=='\n') {lexer_newline(lex);} else {
            lexer_nextChar(lex);
        }
    }
}

TokenType lexer_keyword(const char* base, int len) {
    switch(len) {
        case 2: {
            if(utf8ncmp(base,"if",len) == 0) return TOKEN_KEYWORD_IF;
            return TOKEN_IDENTIFIER;
        }
        case 3: {
            if(utf8ncmp(base,"var",len) == 0) return TOKEN_KEYWORD_VAR;
            if(utf8ncmp(base,"for",len) == 0) return TOKEN_KEYWORD_FOR;
            return TOKEN_IDENTIFIER;
        }
        case 4: {
            if(utf8ncmp(base,"func",len) == 0) return TOKEN_KEYWORD_FUNC;
            if(utf8ncmp(base,"enum",len) == 0) return TOKEN_KEYWORD_ENUM;
            if(utf8ncmp(base,"else",len) == 0) return TOKEN_KEYWORD_ELSE;
            if(utf8ncmp(base,"true",len) == 0) return TOKEN_KEYWORD_TRUE;
            return TOKEN_IDENTIFIER;
        }
        case 5: {
            if(utf8ncmp(base,"class",len) == 0) return TOKEN_KEYWORD_CLASS;
            if(utf8ncmp(base,"match",len) == 0) return TOKEN_KEYWORD_MATCH;
            if(utf8ncmp(base,"break",len) == 0) return TOKEN_KEYWORD_BREAK;
            if(utf8ncmp(base,"false",len) == 0) return TOKEN_KEYWORD_FALSE;
            if(utf8ncmp(base,"super",len) == 0) return TOKEN_KEYWORD_SUPER;
            return TOKEN_IDENTIFIER;
        }
        case 6: {
            if(utf8ncmp(base,"import",len) == 0) return TOKEN_KEYWORD_IMPORT;
            if(utf8ncmp(base,"static",len) == 0) return TOKEN_KEYWORD_STATIC;
            if(utf8ncmp(base,"elseif",len) == 0) return TOKEN_KEYWORD_ELSEIF;
            return TOKEN_IDENTIFIER;
        }
        case 7: {
            if(utf8ncmp(base,"private",len) == 0) return TOKEN_KEYWORD_PRIVATE;
            return TOKEN_IDENTIFIER;
        }
        case 8: {
            if(utf8ncmp(base,"continue",len) == 0) return TOKEN_KEYWORD_CONTINUE;
            return TOKEN_IDENTIFIER;
        }
        default: {
            return TOKEN_IDENTIFIER;
        }
    }
}

Token lexer_scan_identifier(Lexer* lex) {
    utf8_int32_t c = lexer_peekChar(lex);
    while((c=='_')||(c=='.')||isalpha(c)||isdigit(c)||(c>=0xc0)) {
        c = lexer_nextChar(lex);
    }
    lex->pos = utf8rcodepoint(lex->pos,&c);
    lex->colno--;

    if((((uintptr_t)(lex->pos))-((uintptr_t)(lex->start)) == 3)) {
        if(utf8ncmp(lex->start,"vos",3) == 0) {
            err("%s %i:%i Identifier \"vos\" is not fluffy enough. Did you mean \"🦊\"?", lex->filename, lex->lineno, lex->colno); /* Haha, da funny mesg */
        }
    }
    return lexer_add_token(lex, lexer_keyword(lex->start,((uintptr_t)(lex->pos))-((uintptr_t)(lex->start))));
}

static int is_operator (utf8_int32_t c) {
    return ((c == '+') || (c == '-') || (c == '*') || (c == '/') ||
            (c == '<') || (c == '>') || (c == '!') || (c == '=') ||
            (c == '|') || (c == '&') || (c == '^') || (c == '%') ||
            (c == '~') || (c == ':') || (c == ',') || 
            (c == '{') || (c == '}') || (c == '[') || (c == ']') || 
            (c == '(') || (c == ')') );
}

Token lexer_scan_operator(Lexer* lex) {
    utf8_int32_t c = lexer_nextChar(lex);
    utf8_int32_t c2 = lexer_peekChar(lex);

    TokenType token = (TokenType)0;

    switch(c) {
        case '+':
            token = TOKEN_OPERATOR_PLUS;
            break;
        case '-':
            token = TOKEN_OPERATOR_MINUS;
            break;
        case '*':
            token = TOKEN_OPERATOR_MULTIPLY;
            break;
        case '/':
            token = TOKEN_OPERATOR_DIVIDE;
            break;
        case '%':
            token = TOKEN_OPERATOR_MODULO;
            break;
        case '~':
            token = TOKEN_OPERATOR_UNARY_NOT;
            break;
        case '^':
            token = TOKEN_OPERATOR_UNARY_XOR;
            break;
        case '|':
            if(c2 == '|') {lexer_nextChar(lex); token = TOKEN_OPERATOR_BOOL_OR;}
            else token = TOKEN_OPERATOR_UNARY_OR;
            break;
        case '&':
            if(c2 == '&') {lexer_nextChar(lex); token = TOKEN_OPERATOR_BOOL_OR;}
            else token = TOKEN_OPERATOR_UNARY_OR;
            break;
        case '=':
            if(c2 == '=') {lexer_nextChar(lex); token = TOKEN_OPERATOR_EQUAL;}
            else token = TOKEN_OPERATOR_ASSIGN;
            break;
        case '!':
            if(c2 == '=') {lexer_nextChar(lex); token = TOKEN_OPERATOR_NOTEQUAL;}
            else token = TOKEN_OPERATOR_BOOL_NOT;
            break;
        case '<':
            if(c2 == '=') {lexer_nextChar(lex); token = TOKEN_OPERATOR_LESSEQUAL;}
            else if(c2 == '<') {lexer_nextChar(lex); token = TOKEN_OPERATOR_LSHIFT;}
            else token = TOKEN_OPERATOR_LESS;
            break;
        case '>':
            if(c2 == '=') {lexer_nextChar(lex); token = TOKEN_OPERATOR_MOREEQUAL;}
            else if(c2 == '>') {lexer_nextChar(lex); token = TOKEN_OPERATOR_RSHIFT;}
            else token = TOKEN_OPERATOR_MORE;
            break;
        case ':':
            if(c2 == '=') {lexer_nextChar(lex); token = TOKEN_OPERATOR_IMPLY_ASSIGN;}
            else token = TOKEN_OPERATOR_COLON;
            break;
        case ',':
            token = TOKEN_OPERATOR_COMMA;
            break;
        case '(':
            token = TOKEN_OPERATOR_LPAREN;
            break;
        case ')':
            token = TOKEN_OPERATOR_RPAREN;
            break;
        case '[':
            token = TOKEN_OPERATOR_LBRACKET;
            break;
        case ']':
            token = TOKEN_OPERATOR_RBRACKET;
            break;
        case '{':
            token = TOKEN_OPERATOR_LBRACE;
            break;
        case '}':
            token = TOKEN_OPERATOR_RBRACE;
            break;
        default: {
            err("%s %i:%i Unrecognized Operator", lex->filename, lex->lineno, lex->colno);
        }
    }
    return lexer_add_token(lex, token);
}

Token lexer_scan_number(Lexer* lex) {
    TokenType type = TOKEN_INTEGER;
    utf8_int32_t c = lexer_peekChar(lex);
    while((c=='.')||isdigit(c)) {
        c = lexer_nextChar(lex);
        if(c == '.') {
            type = TOKEN_FLOAT;
        }
    }
    lex->pos = utf8rcodepoint(lex->pos,&c);
    lex->colno--;

    return lexer_add_token(lex, type);
}

Token lexer_scan_string(Lexer* lex) {
    lexer_nextChar(lex);
    utf8_int32_t c = lexer_nextChar(lex);
    while(1) {
        if(c == '\0') {err("%s %i:%i EOF while lexing String literal", lex->filename, lex->lineno, lex->colno);}
        if(c == '\n') {err("%s %i:%i EOL while lexing String literal", lex->filename, lex->lineno, lex->colno);}
        if(c == '\\') {
            lexer_nextChar(lex);
            if(lexer_peekChar(lex) == '\0') {err("%s %i:%i EOF while lexing String literal", lex->filename, lex->lineno, lex->colno);}
        }
        if(c == '"') {break;}
        c = lexer_nextChar(lex);
    }
    return lexer_add_token(lex, TOKEN_STRING);
}

Token lexer_next(Lexer* lex) {
    utf8_int32_t c;
loop:
    c = lexer_peekChar(lex);

    if(c=='\0') {return lexer_add_token(lex, TOKEN_NULL);}
    if((c==' ')||(c=='\t')||(c=='\v')||(c=='\f')||(c=='\r')) {lex->pos++; lex->start++; if(c!='\r'){lex->colno++;} goto loop;}
    if(c=='\n') {lexer_newline(lex); goto loop;}
    if((c=='/') && (lexer_peekNextChar(lex)=='*')) {lexer_scan_comment(lex); goto loop;}
    if((c=='_')||isalpha(c)||(c>=0xc0)) {return lexer_scan_identifier(lex);}
    if(is_operator(c)) {return lexer_scan_operator(lex);}
    if(isdigit(c)) {return lexer_scan_number(lex);}
    if(c=='"') {return lexer_scan_string(lex);}

    err("%s %i:%i Unrecognized Token", lex->filename, lex->lineno, lex->colno);
}

Lexer* lexer_new(void* delegate, const char* filename, const char* buffer) {
    Lexer* lex = ((VosDelegate*)delegate)->alloc(sizeof(Lexer));
    lex->delegate = delegate;
    lex->filename = filename;
    lex->buffer = buffer;
    lex->start = buffer;
    lex->pos = buffer;
    lex->length = utf8len(buffer);
    lex->lineno = 1;
    lex->colno = 0;
    return lex;
}