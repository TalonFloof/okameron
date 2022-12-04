#include <vos.h>
#include <parser.h>

VosCompiler* vos_create_compiler(VosDelegate delegate) {
    VosCompiler* comp = delegate.alloc(sizeof(VosCompiler));
    comp->delegate = delegate;
    comp->parser = parser_new(&comp->delegate);
    return comp;
}

VosCompilerOutput vos_compiler_run(VosCompiler* compiler, const char* filename, const char* buffer) {
    VosCompilerOutput output;
    parser_run(compiler->parser,filename,buffer);
    return output;
}

void vos_compiler_free(VosCompiler* compiler) {
    parser_free(compiler->parser);
    compiler->delegate.free(compiler);
}