#ifndef _VOS_ERROR_H
#define _VOS_ERROR_H 1

#include <stdio.h>
#include <stdarg.h>

#define err(...) fprintf(stderr, "\r\x1b[2K\x1b[1;31mVoslang: "); fprintf(stderr, __VA_ARGS__); fprintf(stderr, "\x1b[0m\n"); exit(1);

#endif