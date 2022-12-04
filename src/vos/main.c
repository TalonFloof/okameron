#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <error.h>
#include <sys/time.h>

#include <lexer.h>

int main(int argc, char* argv[]) {
    struct timeval stop, start;
    if(argc == 2) {
        gettimeofday(&start, NULL);
        FILE* f = fopen(argv[1], "rb");
        if((uintptr_t)f == 0) {
            err("Couldn't read file %s!", argv[1]);
            return 1;
        }
        fseek(f, 0, SEEK_END);
        long fsize = ftell(f);
        fseek(f, 0, SEEK_SET);
        uint8_t* content = malloc(fsize + 1);
        if (fread(content, fsize, 1, f) != 1) {
            err("Couldn't read file %s!", argv[1]);
            return 1;
        }
        content[fsize] = 0;
        fclose(f);
        fprintf(stderr, "\r\x1b[2K\x1b[1mLexing...\x1b[0m");
        lexer_parse(argv[1], (const char*)content);
        fprintf(stderr, "\r\x1b[2K");
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