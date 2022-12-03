/*
MIT License

Copyright (c) 2018 Lorca Heeney, 2022-2023 TalonFox

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/* -- HEADER GUARDS -- */
#ifndef LEX_H
#define LEX_H
/* -- INCLUDES -- */
#include<stdlib.h>
#include<stdarg.h>
#include<stdbool.h>
#include<string.h>
#include<regex.h>
#include<tgc.h>
/* -- MACROS -- */
#define MAX_NUM_MATCHES 16
/* -- DATA STRUCTURES -- */
typedef struct {
	char * name;
	char * regex;
} pattern_t;

typedef struct {
	char * type;
	char * str;
} token_t;

struct state_t {
	regex_t * obj;
	pattern_t * patterns;
	unsigned int npatterns;
	token_t * tokens;
	unsigned int ntokens;
	char * buffer;
	unsigned int buffsize;
} * state;

typedef struct {
	token_t * toks;
	unsigned int ntoks;
} results_t;
/* -- PROTOTYPES -- */
results_t lexer(tgc_t* gc, char * source, unsigned int npatterns, ...);
static void tokenize(tgc_t* gc, char * source); 
static void addtoken(tgc_t* gc, char * tokenpattern, char * tokenname);
static void releasetoken(tgc_t* gc, const char * typename);
static void incbuffer(tgc_t* gc, const char c);
static void decbuffer(tgc_t* gc);
static void resetbuffer(tgc_t* gc);
static bool isvalid(tgc_t* gc, const char * pattern, const char * target);
static void initstateconfig(tgc_t* gc, bool new);
/* -- IMPLEMENTATION */
results_t lexer(tgc_t* gc, char * source, unsigned int npatterns, ...){
	initstateconfig(gc,true);
	va_list args;
	va_start(args, npatterns);
    int i;
	for(i = 0 ; i < npatterns; i++){
		addtoken(gc,va_arg(args, char *), va_arg(args, char *));
	}
	va_end(args);
	tokenize(gc,source);
	results_t retval = {.toks = state->tokens, .ntoks = state->ntokens};
	initstateconfig(gc,false);
	return retval;
}

static void tokenize(tgc_t* gc, char * source){
    int i;
    int j;
	for(i = 0 ; i < strlen(source) ; i++){
		if(source[i] == ' ' || source[i] == '\t' || source[i] == '\r') {
			continue;
		}
		incbuffer(gc, source[i]);
		bool success = false;
		char * recentname = NULL;
		for(j = 0 ; j < state->npatterns; j++){
			if(isvalid(gc, state->patterns[j].regex, state->buffer)){
				recentname = state->patterns[j].name;
				success = true;
				break;
			}
		}	
		while(success){
			if(i == strlen(source) - 1){
				if(recentname != NULL){
					releasetoken(gc, recentname);
				}
				break;
			}
			incbuffer(gc, source[++i]);
			success = false;
			for(j = 0 ; j < state->npatterns ; j++){
				if(isvalid(gc, state->patterns[j].regex, state->buffer)){
					recentname = state->patterns[j].name;	
					success = true;
				}
			}
			if(!success){
				i--;
				decbuffer(gc);
				releasetoken(gc, recentname);
				resetbuffer(gc);
				break;
			}
		}
	}
}

static void addtoken(tgc_t* gc, char * tokenpattern, char * tokenname){
	state->patterns = tgc_realloc(gc, state->patterns, (sizeof(pattern_t)*(state->npatterns+1)));
	pattern_t tmp  = {.name = tokenname, .regex = tokenpattern};
	state->patterns[state->npatterns++] = tmp;
}

static void releasetoken(tgc_t* gc, const char * typename){
	state->tokens = tgc_realloc(gc, state->tokens, (sizeof(token_t)*(state->ntokens+1)));
	token_t tmp = {.type = (char*)typename, .str = state->buffer};
	state->tokens[state->ntokens++] = tmp;
}

static void incbuffer(tgc_t* gc, const char c){
	state->buffer = tgc_realloc(gc, state->buffer, (state->buffsize+1));
	state->buffer[state->buffsize++] = c;
	state->buffer[state->buffsize] = '\0';
}

static void decbuffer(tgc_t* gc){
	if(state->buffsize != 0){
		state->buffer = tgc_realloc(gc, state->buffer, (state->buffsize-1));
		state->buffsize--;
	}
}

static void resetbuffer(tgc_t* gc){
	tgc_free(gc, state->buffer);
	state->buffer = tgc_alloc(gc, 1);
	state->buffsize = 0;
}

static bool isvalid(tgc_t* gc, const char * pattern, const char * target){
	regcomp(state->obj, pattern, REG_EXTENDED);
	regmatch_t * matches = tgc_alloc(gc, sizeof(regmatch_t) * MAX_NUM_MATCHES);
	if(regexec(state->obj, target, MAX_NUM_MATCHES, matches, 0) != 0){
		return false;
	}
	const unsigned int len = strlen(target);
	int i;
	for(i = 0 ; i < MAX_NUM_MATCHES ; i++){
		if(matches[i].rm_so == 0 && matches[i].rm_eo == len && matches[i].rm_eo != 0){
			return true;
		} else if (matches[i].rm_so == -1){
			break;
		}
	}
	return false;
}

static void initstateconfig(tgc_t* gc, bool new) {
	if(new){
		state = tgc_alloc(gc, sizeof(struct state_t));
		state->obj = tgc_alloc(gc, sizeof(regex_t));
		state->patterns = tgc_alloc(gc, 1);
		state->tokens = tgc_alloc(gc, 1);
		state->buffer = tgc_alloc(gc, 1);
	}
}
#endif