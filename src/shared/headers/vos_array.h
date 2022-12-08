/*
Adopted from Gravity's Array implementation.
Created by Marco Bambini on 31/07/14.
Copyright (c) 2014 CreoLabs. Licensed under the MIT License.

Vos Implementation by TalonFox.
Copyright (C) 2022-2023. Licensed under the MIT License.
*/
#include <stddef.h>

#include "vos_memory.h"

#ifndef _VOS_ARRAY_H
#define _VOS_ARRAY_H 1

#define ARRAY_DEFAULT_SIZE 8 /* Decreasing this number will reduce performance, but improve memory usage. Increasing this number increases memory usage, but improves performance. */

#define Array(type)                struct {size_t n, m; type *p;}
#define array_init(v)              ((v).n = (v).m = 0, (v).p = 0)
#define array_decl_init(_t,_v)     _t _v; array_init(_v)
#define array_destroy(d,v)         if ((v).p) d->free((v).p)
#define array_get(v, i)            ((v).p[(i)])
#define array_setnull(v, i)        ((v).p[(i)] = NULL)
#define array_pop(v)               ((v).p[--(v).n])
#define array_last(v)              ((v).p[(v).n-1])
#define array_size(v)              ((v).n)
#define array_max(v)               ((v).m)
#define array_inc(v)               (++(v).n)
#define array_dec(v)               (--(v).n)
#define array_nset(v,N)            ((v).n = N)
#define array_push(d, type, v, x)   {if ((v).n == (v).m) {                                        \
                                    (v).m = (v).m? (v).m<<1 : ARRAY_DEFAULT_SIZE;                \
                                    (v).p = (type*)d->realloc((v).p, sizeof(type) * (v).m);}        \
                                    (v).p[(v).n++] = (x);}
#define array_resize(d, type, v, n) (v).m += n; (v).p = (type*)d->realloc((v).p, sizeof(type) * (v).m)
#define array_resize0(d, type, v, n) (v).p = (type*)d->realloc((v).p, sizeof(type) * ((v).m+n));    \
                                    (v).m ? vos_memset((v).p+(sizeof(type) * n), 0, (sizeof(type) * n)) : vos_memset((v).p, 0, (sizeof(type) * n)); (v).m += n
#define array_npop(v,k)            ((v).n -= k)
#define array_reset(v,k)           ((v).n = k)
#define array_reset0(v)            array_reset(v, 0)
#define array_set(v,i,x)           (v).p[i] = (x)

typedef Array(void*) VoidPtrArray;

#endif