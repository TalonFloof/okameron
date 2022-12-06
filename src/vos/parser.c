#include <parser.h>
#include <lexer.h>
#include <vos.h>
#include <utf8.h>
#include <vos_array.h>

#define ACCESS_DELEGATE(d) ((VosDelegate*)d)

Parser* parser_new(void* delegate) {
    Parser* parser = ACCESS_DELEGATE(delegate)->alloc(sizeof(Parser));
    parser->delegate = delegate;
    array_init(parser->lexers);
    return parser;
}

void parser_next_token(Parser* parser) {
    Lexer* lex = array_last(parser->lexers);
    Token token = lexer_next(lex);
    parser->previous = parser->current;
    parser->current = parser->next;
    parser->next = token;
}

void parser_scan_block(Parser* parser, const char* filename) {
    if(parser->current.type != TOKEN_OPERATOR_LBRACE) {
        ACCESS_DELEGATE(parser->delegate)->error_handler("%s %i:%i Code block is Invalid", filename, parser->current.lineno, parser->current.colno);
    }
    while(1) {
        
    }
}

void parser_scan_function(Parser* parser, const char* filename) {
    if(parser->current.type != TOKEN_IDENTIFIER || parser->next.type != TOKEN_OPERATOR_LPAREN) {
        ACCESS_DELEGATE(parser->delegate)->error_handler("%s %i:%i Invalid Function Declaration", filename, parser->previous.lineno, parser->previous.colno);
    }
    parser_next_token(parser);
    while(1) {
        parser_next_token(parser);
        if(parser->current.type == TOKEN_OPERATOR_RPAREN) {
            
        }
    }
}

void parser_scan_class(Parser* parser, const char* filename) {
    if(parser->current.type != TOKEN_IDENTIFIER || (parser->next.type != TOKEN_OPERATOR_LBRACE && parser->next.type != TOKEN_OPERATOR_COLON)) {
        ACCESS_DELEGATE(parser->delegate)->error_handler("%s %i:%i Invalid Class Declaration", filename, parser->previous.lineno, parser->previous.colno);
    }
}

void parser_scan_variable(Parser* parser, const char* filename) {
    if(parser->current.type != TOKEN_IDENTIFIER || parser->next.type != TOKEN_IDENTIFIER) {
        ACCESS_DELEGATE(parser->delegate)->error_handler("%s %i:%i Invalid Variable Declaration", filename, parser->previous.lineno, parser->previous.colno);
    }
    parser_next_token(parser);
}

static const char* keywordNames[] = {
    "TOKEN_NULL",
    "TOKEN_STRING",
    "TOKEN_INTEGER",
    "TOKEN_FLOAT",
    "TOKEN_IDENTIFIER",

    "TOKEN_KEYWORD_FUNC",
    "TOKEN_KEYWORD_STATIC_FUNC",
    "TOKEN_KEYWORD_CLASS",
    "TOKEN_KEYWORD_ENUM",
    "TOKEN_KEYWORD_IMPORT",
    "TOKEN_KEYWORD_VAR",
    "TOKEN_KEYWORD_STATIC_VAR",
    "TOKEN_KEYWORD_PRIVATE",
    "TOKEN_KEYWORD_STATIC_PRIVATE",
    "TOKEN_KEYWORD_IF",
    "TOKEN_KEYWORD_ELSEIF",
    "TOKEN_KEYWORD_ELSE",
    "TOKEN_KEYWORD_MATCH",
    "TOKEN_KEYWORD_WHILE",
    "TOKEN_KEYWORD_FOR",
    "TOKEN_KEYWORD_BREAK",
    "TOKEN_KEYWORD_CONTINUE",
    "TOKEN_KEYWORD_RETURN",
    "TOKEN_KEYWORD_TRUE",
    "TOKEN_KEYWORD_FALSE",
    "TOKEN_KEYWORD_NULL",
    "TOKEN_KEYWORD_SUPER",

    "TOKEN_OPERATOR_PLUS",
    "TOKEN_OPERATOR_MINUS",
    "TOKEN_OPERATOR_MULTIPLY",
    "TOKEN_OPERATOR_DIVIDE",
    "TOKEN_OPERATOR_MODULO",
    "TOKEN_OPERATOR_UNARY_NOT",
    "TOKEN_OPERATOR_UNARY_XOR",
    "TOKEN_OPERATOR_UNARY_OR",
    "TOKEN_OPERATOR_UNARY_AND",
    "TOKEN_OPERATOR_LSHIFT",
    "TOKEN_OPERATOR_RSHIFT",
    "TOKEN_OPERATOR_BOOL_NOT",
    "TOKEN_OPERATOR_BOOL_OR",
    "TOKEN_OPERATOR_BOOL_AND",
    "TOKEN_OPERATOR_EQUAL",
    "TOKEN_OPERATOR_NOTEQUAL",
    "TOKEN_OPERATOR_LESS",
    "TOKEN_OPERATOR_MORE",
    "TOKEN_OPERATOR_LESSEQUAL",
    "TOKEN_OPERATOR_MOREEQUAL",
    "TOKEN_OPERATOR_ASSIGN",
    "TOKEN_OPERATOR_IMPLY_ASSIGN",
    "TOKEN_OPERATOR_COLON",
    "TOKEN_OPERATOR_COMMA",
    "TOKEN_OPERATOR_LPAREN",
    "TOKEN_OPERATOR_RPAREN",
    "TOKEN_OPERATOR_LBRACKET",
    "TOKEN_OPERATOR_RBRACKET",
    "TOKEN_OPERATOR_LBRACE",
    "TOKEN_OPERATOR_RBRACE",
};

void parser_run(Parser* parser, const char* filename, const char* buffer) {
    if(((uintptr_t)filename) == 0) {
        filename = "[anonymous buffer]";
    }
    parser->previous.type = TOKEN_NULL;
    parser->previous.start = buffer;
    parser->previous.length = 0;
    parser->current.type = TOKEN_NULL;
    parser->current.start = buffer;
    parser->current.length = 0;
    parser->next.type = TOKEN_NULL;
    parser->next.start = buffer;
    parser->next.length = 0;
    array_push(ACCESS_DELEGATE(parser->delegate), void*, parser->lexers, lexer_new(parser->delegate, filename, buffer));
    parser_next_token(parser); /* Go ahead and grab the next token. */
    while(1) {
        parser_next_token(parser);
        if(parser->previous.type == TOKEN_NULL && parser->current.type == TOKEN_NULL && parser->next.type == TOKEN_NULL) {
            break;
        }
        /*PRINT(parser->delegate,"% 32s | %.*s\n", keywordNames[(int)(parser->current.type)], parser->current.length, parser->current.start);*/
        switch(parser->previous.type) {
            case TOKEN_KEYWORD_STATIC_FUNC:
            case TOKEN_KEYWORD_FUNC:
                parser_scan_function(parser,filename);
                break;
            case TOKEN_KEYWORD_CLASS:
                parser_scan_class(parser,filename);
                break;
            case TOKEN_KEYWORD_STATIC_VAR:
            case TOKEN_KEYWORD_STATIC_PRIVATE:
            case TOKEN_KEYWORD_VAR:
            case TOKEN_KEYWORD_PRIVATE:
                parser_scan_variable(parser,filename);
                break;
            case TOKEN_KEYWORD_ENUM:
                break;
            default:
                switch(parser->current.type) {
                    case TOKEN_IDENTIFIER:
                        ACCESS_DELEGATE(parser->delegate)->error_handler("%s %i:%i Isolated Identifier", filename, parser->previous.lineno, parser->previous.colno);
                        break;
                    default:
                        break;
                }
                break;
        }
    }
    ACCESS_DELEGATE(parser->delegate)->free(array_last(parser->lexers));
    array_pop(parser->lexers);
}

void parser_free(Parser* parser) {
    int i;
    for(i = 0; i < array_size(parser->lexers); i++) {
        ACCESS_DELEGATE(parser->delegate)->free(array_get(parser->lexers, i));
    }
    array_destroy(ACCESS_DELEGATE(parser->delegate),parser->lexers);
    ACCESS_DELEGATE(parser->delegate)->free(parser);
}