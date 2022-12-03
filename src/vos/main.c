#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <error.h>

#include <lexer.h>

int main(int argc, char* argv[]) {
    if(argc == 2) {
        FILE* f = fopen(argv[1], "rb");
        if((uintptr_t)f == 0) {
            error("Couldn't read file %s!", argv[1]);
            return 1;
        }
        fseek(f, 0, SEEK_END);
        long fsize = ftell(f);
        fseek(f, 0, SEEK_SET);
        uint8_t* content = malloc(fsize + 1);
        if (fread(content, fsize, 1, f) != 1) {
            error("Couldn't read file %s!", argv[1]);
            return 1;
        }
        content[fsize] = 0;
        fclose(f);
        lexer_parse((char*)content);
    } else {
        fprintf(stderr, "Usage: vos <file.vos>\n");
        return 0;
    }
    return 0;
}