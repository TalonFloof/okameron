#ifndef _VOS_VOS_H
#define _VOS_VOS_H 1

#include "parser.h"
#include "lexer.h"
#include <stddef.h>

typedef void* (*VosAllocateHandler)(size_t size);
typedef void* (*VosReallocateHandler)(void* ptr, size_t newsize);
typedef void  (*VosFreeHandler)(void* ptr);
typedef void  (*VosErrorHandler)(const char* message,...);
typedef int   (*VosPrintFHandler)(const char*,...);

typedef struct {
    /* These four functions MUST be implemented! */
    VosAllocateHandler alloc;
    VosReallocateHandler realloc;
    VosFreeHandler free;
    VosErrorHandler error_handler;

    VosPrintFHandler printf;
} VosDelegate;

typedef struct {
    VosDelegate delegate;
    Parser* parser;
} VosCompiler;

typedef struct {
    void* base;
    uint64_t length;
} VosCompilerOutput;

#define PRINT(d,...) ((VosDelegate*)d)->printf(__VA_ARGS__)

VosCompiler* vos_create_compiler(VosDelegate delegate);
VosCompilerOutput vos_compiler_run(VosCompiler* compiler, const char* filename, const char* buffer);
void vos_compiler_free(VosCompiler* compiler);

#endif