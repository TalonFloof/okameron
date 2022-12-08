#ifndef _VOS_PARSER_H
#define _VOS_PARSER_H 1

#include <stdint.h>
#include <stddef.h>
#include "../../shared/headers/vos_array.h"
#include "lexer.h"

typedef enum {
    NULL_NODE = 0, /* Self-explanitory */
    COMPOUND_STATEMENT, /* A vector of AST Nodes basically */
    LIST_STATEMENT, /* Same as COMPOUND_STATMENT, but has a static type. Used for arrays. */
    LOOP_STATEMENT, /* For loop */
    JUMP_STATMENT, /* Break, Continue, and Return. */
    FLOW_STATMENT, /* If, Elseif, Else, and Match. */

    ENUM_DECLARE, /* Enum declaration */
    FUNCTION_DECLARE, /* Function declaration */
    VARIABLE_DECLARE, /* Variable declaration */
    CLASS_DECLARE, /* Class declaration */
    VARIABLE_CHANGE, /* Variable modification */

    KEYWORD_EXPR, 
    LITERAL_EXPR, /* A literal value, such as an integer, float, string, etc. */
    UNARY_EXPR, /* Operation with one value. Ex: Not, And, Or, Xor, etc. */
    BINARY_EXPR, /* Operation with two values. Ex: addition, subtract, multiplication, etc. */
    FUNCTION_EXPR, /* Function call */ 
} ASTNodeType;

typedef struct {
    ASTNodeType type;
    int size;
    void* declaration; /* Declaration of this node's object if available. Not filled out until phase 2. */
} ASTNode;

typedef Array(ASTNode*) ASTArray;

typedef struct {
    ASTNode super;
    ASTArray* vector;
} ASTNode_Compound;

typedef struct {
    ASTNode super;
    
} ASTNode_Loop;

typedef struct { /* Must be void pointers to prevent cyclic dependency issues */
    void* delegate;
    char* buffer;
    uint32_t length;
    VoidPtrArray lexers;

    Token previous;
    Token current;
    Token next;
} Parser;

Parser* parser_new(void* compiler);
void parser_run(Parser* parser, const char* filename, const char* buffer);
void parser_free(Parser* parser);

#endif