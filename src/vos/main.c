#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <error.h>
#include <sys/time.h>

#include <lexer.h>

void compile_file(const char* path) {
    FILE* f = fopen(path, "rb");
    if((uintptr_t)f == 0) {
        err("Couldn't read file %s!", path);
        exit(1);
    }
    fseek(f, 0, SEEK_END);
    long fsize = ftell(f);
    fseek(f, 0, SEEK_SET);
    uint8_t* content = malloc(fsize + 1);
    if (fread(content, fsize, 1, f) != 1) {
        err("Couldn't read file %s!", path);
        exit(1);
    }
    content[fsize] = 0;
    fclose(f);
    fprintf(stderr, "\r\x1b[2K\x1b[1mLexing %s...\x1b[0m", path);
    Lexer result = lexer_parse(path, (const char*)content);
    fprintf(stderr, "\r\x1b[2KParsing %s...\x1b[0m", path);
    fprintf(stderr, "\r\x1b[2KCompiling %s...\x1b[0m", path);
    free(content);
}

int main(int argc, char* argv[]) {
    struct timeval stop, start;
    if(argc == 2) {
        gettimeofday(&start, NULL);
        compile_file(argv[1]);
        gettimeofday(&stop, NULL);
        double start_timestamp = (double)((start.tv_sec*1000)+(start.tv_usec/1000));
        double stop_timestamp = (double)((stop.tv_sec*1000)+(stop.tv_usec/1000));
        fprintf(stderr, "\x1b[1mSuccessfully compiled in %.3fs\x1b[0m", (stop_timestamp-start_timestamp)/1000.0);
    } else {
        fprintf(stderr, "Usage: vos <file.vos>\n");
        return 0;
    }
    return 0;
}