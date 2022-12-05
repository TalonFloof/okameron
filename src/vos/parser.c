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

void parser_scan_function(Parser* parser, const char* filename) {
    if(parser->current.type != TOKEN_IDENTIFIER || parser->next.type != TOKEN_OPERATOR_LPAREN) {
        ACCESS_DELEGATE(parser->delegate)->error_handler("%s %i:%i Invalid Function Declaration", filename, parser->previous.lineno, parser->previous.colno);
    }
    /*while(1) {
        
    }*/
}

void parser_scan_class(Parser* parser, const char* filename) {
    if(parser->current.type != TOKEN_IDENTIFIER || (parser->next.type != TOKEN_OPERATOR_LBRACE&&parser->next.type != TOKEN_OPERATOR_COLON)) {
        ACCESS_DELEGATE(parser->delegate)->error_handler("%s %i:%i Invalid Class Declaration", filename, parser->previous.lineno, parser->previous.colno);
    }
}

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
        if(parser->current.type == TOKEN_NULL) {
            break;
        }
        PRINT(parser->delegate,"%04i | %.*s\n", parser->current.type, parser->current.length, parser->current.start);
        switch(parser->previous.type) {
            case TOKEN_KEYWORD_FUNC:
                parser_scan_function(parser,filename);
                break;
            case TOKEN_KEYWORD_CLASS:
                parser_scan_class(parser,filename);
                break;
            case TOKEN_KEYWORD_ENUM:
                break;
            default:
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