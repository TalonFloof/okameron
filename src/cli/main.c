#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sys/time.h>
#include <string.h>

#include <vos.h>

void err(const char* format,...) {
    fprintf(stderr, "\x1b[1;31mVoslang: ");
    va_list argptr;
    va_start(argptr, format);
    vfprintf(stderr, format, argptr);
    va_end(argptr);
    fprintf(stderr, "\x1b[0m\n");
    exit(1);
}

char* read_file(const char* path) {
    FILE* f = fopen(path, "rb");
    if((uintptr_t)f == 0) {
        err("Couldn't read file %s!", path);
        exit(1);
    }
    fseek(f, 0, SEEK_END);
    long fsize = ftell(f);
    fseek(f, 0, SEEK_SET);
    char* content = malloc(fsize + 1);
    if (fread(content, fsize, 1, f) != 1) {
        err("Couldn't read file %s!", path);
        exit(1);
    }
    content[fsize] = 0;
    fclose(f);
    return content;
}

int main(int argc, char* argv[]) {
    struct timeval stop, start;
    if(argc == 3) {
        if(strcmp(argv[1],"build") == 0) {
            gettimeofday(&start, NULL);
            char* data = read_file(argv[2]);
            VosDelegate delegate = (VosDelegate){.alloc = malloc, .realloc = realloc, .free = free, .error_handler = err, .printf = printf};

            VosCompiler* compiler = vos_create_compiler(delegate,NULL);
            vos_compiler_run(compiler,argv[2],data);

            gettimeofday(&stop, NULL);
            double start_timestamp = (double)((start.tv_sec*1000)+(start.tv_usec/1000));
            double stop_timestamp = (double)((stop.tv_sec*1000)+(stop.tv_usec/1000));
            fprintf(stderr, "\x1b[1mSuccessfully compiled in %.3fs\x1b[0m", (stop_timestamp-start_timestamp)/1000.0);
        }
    } else {
        fprintf(stderr, "Usage: vos build <file.vos>\n       vos run <file.vos>\n       vos exec <file.vbc>\n");
        return 0;
    }
    return 0;
}