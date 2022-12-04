#include <parser.h>
#include <lexer.h>
#include <vos.h>
#include <utf8.h>

#define ACCESS_DELEGATE(d) ((VosDelegate*)d)

Parser* parser_new(void* delegate) {
    Parser* parser = ACCESS_DELEGATE(delegate)->alloc(sizeof(Parser));
    parser->delegate = delegate;
    return parser;
}



void parser_free(Parser* parser) {
    int i;
    for(i = 0; i < array_size(parser->lexers); i++) {
        ACCESS_DELEGATE(parser->delegate)->free(array_get(parser->lexers, i));
    }
    array_destroy(ACCESS_DELEGATE(parser->delegate),parser->lexers);
    ACCESS_DELEGATE(parser->delegate)->free(parser);
}