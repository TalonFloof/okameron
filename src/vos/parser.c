#include <parser.h>
#include <lexer.h>
#include <vos.h>
#include <utf8.h>
#include <vos_array.h>

#define ACCESS_DELEGATE(d) ((VosDelegate *)d)

typedef Array(Token) TokenList;

static const char *keywordNames[] = {
    "TOKEN_NULL",
    "TOKEN_STRING",
    "TOKEN_INTEGER",
    "TOKEN_FLOAT",
    "TOKEN_IDENTIFIER",

    "TOKEN_KEYWORD_FUNC",
    "TOKEN_KEYWORD_CLASS",
    "TOKEN_KEYWORD_ENUM",
    "TOKEN_KEYWORD_IMPORT",
    "TOKEN_KEYWORD_VAR",
    "TOKEN_KEYWORD_PRIVATE",
    "TOKEN_KEYWORD_IF",
    "TOKEN_KEYWORD_ELSEIF",
    "TOKEN_KEYWORD_ELSE",
    "TOKEN_KEYWORD_MATCH",
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
    "TOKEN_OPERATOR_POWER",
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

Parser *parser_new(void *delegate)
{
    Parser *parser = ACCESS_DELEGATE(delegate)->alloc(sizeof(Parser));
    parser->delegate = delegate;
    parser->fetch_on_next = 1;
    array_init(parser->lexers);
    array_init(parser->scopes);
    return parser;
}

void parser_next_token(Parser *parser)
{
    Lexer *lex = array_last(parser->lexers);
    Token token = lexer_next(lex);
    parser->current = token;
    PRINT(parser->delegate, "% 32s | %.*s\n", keywordNames[(int)(token.type)], token.length, token.start);
}

void parser_error(Parser *parser, const char *msg)
{
    ACCESS_DELEGATE(parser->delegate)->error_handler("%s %i:%i %s", ((Lexer *)array_last(parser->lexers))->filename, parser->current.lineno, parser->current.colno, msg);
}

void parser_push_scope(Parser *parser, ScopeType type)
{
    array_push(ACCESS_DELEGATE(parser->delegate), ScopeType, parser->scopes, type);
}

void parser_pop_scope(Parser *parser)
{
    (void)array_pop(parser->scopes);
}

ScopeType parser_get_scope_type(Parser *parser)
{
    if (array_size(parser->scopes) == 0)
    {
        return SCOPE_FILE;
    }
    else
    {
        return array_last(parser->scopes);
    }
}

int parser_get_scope_level(Parser *parser)
{
    return array_size(parser->scopes);
}

void parser_expect_token(Parser *parser, TokenType type, const char *failureMsg)
{
    parser_next_token(parser);
    if (parser->current.type != type)
    {
        parser_error(parser, failureMsg);
    }
}

void parser_scan_function(Parser *parser)
{
    parser_expect_token(parser, TOKEN_IDENTIFIER, "Expected identifier within function definition");
    Token name = parser->current;
    parser_expect_token(parser, TOKEN_OPERATOR_LPAREN, "Expected \"(\" after function identifier");
    while (1)
    {
        parser_next_token(parser);
        if (parser->current.type == TOKEN_OPERATOR_RPAREN)
        {
            break;
        }
        else if (parser->current.type == TOKEN_NULL)
        {
            parser_error(parser, "Function arguments extends beyond EOF");
        }
    }
    parser_push_scope(parser, SCOPE_FUNCTION);
}

void parser_scan_class(Parser *parser)
{
    Token name, superName;
    superName.type = TOKEN_NULL;
    parser_expect_token(parser, TOKEN_IDENTIFIER, "Expected identifier within class definition");
    name = parser->current;
    parser_next_token(parser);
    if (parser->current.type == TOKEN_OPERATOR_COLON)
    {
        parser_expect_token(parser, TOKEN_IDENTIFIER, "Expected superclass identifier within class definition");
        superName = parser->current;
        parser_next_token(parser);
    }
    if (parser->current.type != TOKEN_OPERATOR_LBRACE)
    {
        parser_error(parser, "Expected \"{\" after class identifier(s)");
    }
    parser_push_scope(parser, SCOPE_CLASS);
}

void parser_scan_variable(Parser *parser)
{
    if (parser_get_scope_type(parser) == SCOPE_FILE)
    {
        parser_error(parser, "By intentional design, Vos doesn't allow global variables to be defined (A compiler flag will allow globals in the future)");
    }
}

/*
    Huge credit to https://journal.stuffwithstuff.com/2011/03/19/pratt-parsers-expression-parsing-made-easy/
    for helping me figure out pratt expression parsing.
*/

ASTNode *parser_scan_literal(Parser *parser)
{
    return (ASTNode *)0;
}

ASTNode *parser_scan_infix(Parser *parser)
{
    return (ASTNode *)0;
}

ASTNode *parser_scan_unary(Parser *parser)
{
    return (ASTNode *)0;
}

ASTNode *parser_scan_identifier(Parser *parser)
{
    return (ASTNode *)0;
}

ASTNode *parser_scan_paren(Parser *parser)
{
    return (ASTNode *)0;
}

ASTNode *parser_scan_call(Parser *parser)
{
    return (ASTNode *)0;
}

typedef enum
{
    PREC_NONE = 0,
    PREC_LOW,
    PREC_ASSIGNMENT, /* := = */
    PREC_LOGIC,      /* && || */
    PREC_COMPARISON, /* == != > < >= <= */
    PREC_TERM,       /* + - | ^ & */
    PREC_FACTOR,     /* * / % */
    PREC_EXPONENT,   /* ** */
    PREC_UNARY,      /* ~ ! */
    PREC_SHIFT,      /* >> << */
    PREC_CALL,       /* func() */
} PrecedenceLevel;

typedef ASTNode *(*ASTParseFunc)(Parser *parser);

typedef struct
{
    ASTParseFunc prefix;
    ASTParseFunc infix;
    PrecedenceLevel precedence;
    const char *name;
} SyntacticRule;

#define UNUSED                      \
    {                               \
        NULL, NULL, PREC_NONE, NULL \
    }
#define PREFIX(prec, fn)     \
    {                        \
        fn, NULL, prec, NULL \
    }
#define INFIX(prec, fn)      \
    {                        \
        NULL, fn, prec, NULL \
    }
#define INFIX_OPERATOR(prec, name)          \
    {                                       \
        NULL, parser_scan_infix, prec, name \
    }
#define PREFIX_OPERATOR(prec, name)         \
    {                                       \
        parser_scan_unary, NULL, prec, name \
    }
#define OPERATOR(prec, name)                             \
    {                                                    \
        parser_scan_unary, parser_scan_infix, prec, name \
    }

SyntacticRule syntacticRules[] = {
    UNUSED,
    PREFIX(PREC_LOW, parser_scan_literal),
    PREFIX(PREC_LOW, parser_scan_literal),
    PREFIX(PREC_LOW, parser_scan_literal),
    PREFIX(PREC_LOW, parser_scan_identifier),

    UNUSED,
    UNUSED,
    UNUSED,
    UNUSED,
    UNUSED,
    UNUSED,
    UNUSED,
    UNUSED,
    UNUSED,
    UNUSED,
    UNUSED,
    UNUSED,
    UNUSED,
    UNUSED,
    PREFIX(PREC_LOW, parser_scan_literal),
    PREFIX(PREC_LOW, parser_scan_literal),
    UNUSED,
    UNUSED,

    OPERATOR(PREC_TERM, "+"),
    OPERATOR(PREC_TERM, "-"),
    INFIX_OPERATOR(PREC_FACTOR, "*"),
    INFIX_OPERATOR(PREC_FACTOR, "/"),
    INFIX_OPERATOR(PREC_FACTOR, "%"),
    INFIX_OPERATOR(PREC_EXPONENT, "**"),
    PREFIX_OPERATOR(PREC_UNARY, "~"),
    INFIX_OPERATOR(PREC_TERM, "^"),
    INFIX_OPERATOR(PREC_TERM, "|"),
    INFIX_OPERATOR(PREC_TERM, "&"),
    INFIX_OPERATOR(PREC_SHIFT, "<<"),
    INFIX_OPERATOR(PREC_SHIFT, ">>"),
    PREFIX_OPERATOR(PREC_UNARY, "!"),
    INFIX_OPERATOR(PREC_LOGIC, "||"),
    INFIX_OPERATOR(PREC_LOGIC, "&&"),
    INFIX_OPERATOR(PREC_COMPARISON, "=="),
    INFIX_OPERATOR(PREC_COMPARISON, "!="),
    INFIX_OPERATOR(PREC_COMPARISON, "<"),
    INFIX_OPERATOR(PREC_COMPARISON, ">"),
    INFIX_OPERATOR(PREC_COMPARISON, "<="),
    INFIX_OPERATOR(PREC_COMPARISON, ">="),
    INFIX_OPERATOR(PREC_ASSIGNMENT, "="),
    INFIX_OPERATOR(PREC_ASSIGNMENT, ":="),
    UNUSED,
    UNUSED,
    {parser_scan_paren, parser_scan_call, PREC_CALL, NULL},
    UNUSED,
    UNUSED,
    UNUSED,
    UNUSED,
    UNUSED,
};

void parser_scan_expression(Parser *parser)
{
    /*TokenList tokens;
    array_init(tokens);
    array_push(ACCESS_DELEGATE(parser->delegate), Token, tokens, parser->current);
    int runLoop = 1;
    int allowIdentifiers = 0;
    int prevIdentAllow = 0;
    while(runLoop) {
        prevIdentAllow = allowIdentifiers;
        parser_next_token(parser);
        if(allowIdentifiers) {allowIdentifiers = 0;}
        switch(parser->current.type) {
            case TOKEN_IDENTIFIER:
                if(prevIdentAllow) {
                    array_push(ACCESS_DELEGATE(parser->delegate), Token, tokens, parser->current);
                } else {
                    runLoop = 0;
                }
                break;
            case TOKEN_INTEGER:
            case TOKEN_FLOAT:
            case TOKEN_STRING:
            case TOKEN_KEYWORD_TRUE:
            case TOKEN_KEYWORD_FALSE:
                array_push(ACCESS_DELEGATE(parser->delegate), Token, tokens, parser->current);
                break;
            case TOKEN_OPERATOR_PLUS:
            case TOKEN_OPERATOR_MINUS:
            case TOKEN_OPERATOR_MULTIPLY:
            case TOKEN_OPERATOR_DIVIDE:
            case TOKEN_OPERATOR_MODULO:
            case TOKEN_OPERATOR_POWER:
            case TOKEN_OPERATOR_UNARY_NOT:
            case TOKEN_OPERATOR_UNARY_XOR:
            case TOKEN_OPERATOR_UNARY_OR:
            case TOKEN_OPERATOR_UNARY_AND:
            case TOKEN_OPERATOR_LSHIFT:
            case TOKEN_OPERATOR_RSHIFT:
            case TOKEN_OPERATOR_BOOL_NOT:
            case TOKEN_OPERATOR_BOOL_OR:
            case TOKEN_OPERATOR_BOOL_AND:
            case TOKEN_OPERATOR_EQUAL:
            case TOKEN_OPERATOR_NOTEQUAL:
            case TOKEN_OPERATOR_LESS:
            case TOKEN_OPERATOR_MORE:
            case TOKEN_OPERATOR_LESSEQUAL:
            case TOKEN_OPERATOR_MOREEQUAL:
            case TOKEN_OPERATOR_ASSIGN:
            case TOKEN_OPERATOR_IMPLY_ASSIGN:
            case TOKEN_OPERATOR_COMMA:
            case TOKEN_OPERATOR_LPAREN:
                array_push(ACCESS_DELEGATE(parser->delegate), Token, tokens, parser->current);
                allowIdentifiers = 1;
                break;
            case TOKEN_OPERATOR_RPAREN:
                array_push(ACCESS_DELEGATE(parser->delegate), Token, tokens, parser->current);
                break;
            default:
                runLoop = 0;
                break;
        }
    }
    parser->fetch_on_next = 0;*/
    /* Now it's time to actually try to figure out what the expression is doing */
    /*int precedence;
    int index;*/
    /* Evaluate Precedence Level 1 and beyond */
    /*for(precedence=1;precedence < 9;precedence++) {
        for(index=0;index < array_size(tokens);index++) {
            Token token = array_get(tokens,index);
            switch(precedence) {
                case 1:

                    break;
            }
        }
    }
    array_destroy(ACCESS_DELEGATE(parser->delegate),tokens);*/
}

void parser_run(Parser *parser, const char *filename, const char *buffer)
{
    if (((uintptr_t)filename) == 0)
    {
        filename = "[anonymous buffer]";
    }
    parser->current.type = TOKEN_NULL;
    parser->current.start = buffer;
    parser->current.length = 0;
    array_push(ACCESS_DELEGATE(parser->delegate), void *, parser->lexers, lexer_new(parser->delegate, filename, buffer));
    while (1)
    {
        if (!parser->fetch_on_next)
        {
            parser->fetch_on_next = 1;
        }
        else
        {
            parser_next_token(parser);
        }
        if (parser->current.type == TOKEN_NULL)
            break;
        switch (parser->current.type)
        {
        case TOKEN_KEYWORD_FUNC:
            parser_scan_function(parser);
            break;
        case TOKEN_KEYWORD_CLASS:
            parser_scan_class(parser);
            break;
        case TOKEN_KEYWORD_VAR:
            parser_scan_variable(parser);
            break;
        case TOKEN_KEYWORD_PRIVATE:
            if (parser_get_scope_type(parser) == SCOPE_FILE)
            {
                parser_error(parser, "By intentional design, Vos doesn't allow global variables to be defined (A compiler flag will allow globals in the future)");
            }
            else if (parser_get_scope_type(parser) != SCOPE_CLASS)
            {
                parser_error(parser, "Private variables cannot be defined outside of a class scope");
            }
            parser_scan_variable(parser);
            break;
        case TOKEN_KEYWORD_ENUM:
            parser_push_scope(parser, SCOPE_ENUM); /*Temporary*/
            break;
        case TOKEN_KEYWORD_FOR:
            parser_push_scope(parser, SCOPE_FOR); /*Temporary*/
            break;
        case TOKEN_OPERATOR_RBRACE:
            if (array_size(parser->scopes) == 0)
            {
                parser_error(parser, "Isolated \"}\"");
            }
            else
            {
                parser_pop_scope(parser);
            }
            break;
        case TOKEN_IDENTIFIER:
        case TOKEN_INTEGER:
        case TOKEN_FLOAT:
            parser_scan_expression(parser);
            break;
        default:
            break;
        }
    }
    if (array_size(parser->scopes) > 0)
    {
        parser_error(parser, "One or more scope(s) extends beyond EOF");
    }
    ACCESS_DELEGATE(parser->delegate)->free(array_last(parser->lexers));
    (void)array_pop(parser->lexers);
}

void parser_free(Parser *parser)
{
    int i;
    for (i = 0; i < array_size(parser->lexers); i++)
    {
        ACCESS_DELEGATE(parser->delegate)->free(array_get(parser->lexers, i));
    }
    array_destroy(ACCESS_DELEGATE(parser->delegate), parser->lexers);
    array_destroy(ACCESS_DELEGATE(parser->delegate), parser->scopes);
    ACCESS_DELEGATE(parser->delegate)->free(parser);
}