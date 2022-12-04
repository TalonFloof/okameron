#ifndef _VOS_VOS_H
#define _VOS_VOS_H 1

#include "parser.h"
#include "lexer.h"

typedef enum {
    TARGET_VOSVM_BYTECODE,
    TARGET_C
} VosTargetType;

typedef 

typedef struct {
    VosTargetType target;
    Parser* parser;

} VosCompiler;

VosCompiler vos_create_compiler(VosTargetType target);

#endif