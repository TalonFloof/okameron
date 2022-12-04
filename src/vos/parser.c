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

void parser_run(Parser* parser, const char* filename, const char* buffer) {
    if(((uintptr_t)filename) == 0) {
        filename = "[anonymous buffer]";
    }
    array_push(ACCESS_DELEGATE(parser->delegate), void*, parser->lexers, lexer_new(parser->delegate, filename, buffer));
    Lexer* lex = array_last(parser->lexers);
    Token token;
    while(1) {
        token = lexer_next(lex);
        PRINT(parser->delegate,"%04i | %.*s\n", token.type, token.length, token.start);
        if(token.type == TOKEN_NULL) {
            break;
        }
    }
    ACCESS_DELEGATE(parser->delegate)->free(lex);
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