#ifndef _VOS_VOS_H
#define _VOS_VOS_H 1

#include "parser.h"
#include "lexer.h"

typedef enum {
    TARGET_VOSVM_BYTECODE,
    TARGET_C
} VosTargetType;

typedef void* (*VosAllocateHandler)(size_t size);
typedef void* (*VosReallocateHandler)(void* ptr, size_t newsize);
typedef void  (*VosFreeHandler)(void* ptr);
typedef void  (*VosErrorHandler)(const char* message,...);

typedef struct {
    VosTargetType target;

    /* These three functions MUST be implemented! */
    VosAllocateHandler alloc;
    VosReallocateHandler realloc;
    VosFreeHandler free;
    VosErrorHandler error_handler;
} VosDelegate;

typedef struct {
    VosDelegate delegate;
    Parser* parser;
} VosCompiler;

typedef struct {
    void* base;
    uint64_t length;
} VosCompilerOutput;

VosCompiler* vos_create_compiler(VosDelegate delegate);
VosCompilerOutput vos_compiler_run(VosCompiler* compiler, const char* filename, const char* buffer, uint32_t length);
void vos_compiler_free(VosCompiler* compiler);

#endif