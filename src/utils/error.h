#ifndef _VOS_ERROR_H
#define _VOS_ERROR_H 1

#include <stdio.h>
#include <stdarg.h>
#include <tgc.h>

#define error(...) fprintf(stderr, "\x1b[31mVoslang: "); fprintf(stderr, __VA_ARGS__); fprintf(stderr, "\x1b[0m\n"); tgc_stop(&vosGC); exit(1);

#endif