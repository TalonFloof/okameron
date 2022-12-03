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
#define LEX_H 1
/* -- INCLUDES -- */
#include<stdint.h>
#include<stdlib.h>
#include<stdarg.h>
#include<stdbool.h>
#include<string.h>
#include<regex.h>

#include<error.h>
/* -- MACROS -- */
#define MAX_NUM_MATCHES 6
#define MAX_NUM_PATTERNS (9+18)
/* -- DATA STRUCTURES -- */
typedef struct {
	char * name;
	char * regex;
} pattern_t;

typedef struct {
	char * type;
	char * str;
} token_t;

static struct state_t {
	regex_t * obj;
	pattern_t * patterns;
	unsigned int npatterns;
	token_t * tokens;
	unsigned int ntokens;
	char * buffer;
	unsigned int buffsize;

	uint32_t line;
	uint32_t col;

	uint32_t prev_col;

	uint32_t start_line;
	uint32_t start_col;
} *state;

typedef struct {
	token_t * toks;
	unsigned int ntoks;
} results_t;
/* -- PROTOTYPES -- */
static results_t lexer(char * source, unsigned int npatterns, ...);
static void tokenize(char * source); 
static void addtoken(char * tokenpattern, char * tokenname);
static void releasetoken(const char * typename_);
static void incbuffer(const char c);
static void decbuffer(void);
static void resetbuffer(void);
static bool isvalid(const char * pattern, const char * target);
static void initstateconfig(bool new_);
/* -- IMPLEMENTATION */
static results_t lexer(char * source, unsigned int npatterns, ...){
	initstateconfig(true);
	va_list args;
	va_start(args, npatterns);		
	int i;
	for(i = 0 ; i < npatterns; i++){
		addtoken(va_arg(args, char *), va_arg(args, char *));
	}
	va_end(args);
	tokenize(source);
	if(state->buffsize > 1) {
		err("Unknown token \"\x1b[1m%c\x1b[0;31m\" at %i:%i", state->buffer[0], state->start_line, state->start_col-1);
	}
	results_t retval = {.toks = state->tokens, .ntoks = state->ntokens};
	initstateconfig(false);
	return retval;
}

static void tokenize(char * source){
	int i;
	int j;
	for(i = 0 ; i < strlen(source) ; i++){
		if((source[i] == ' ') || source[i] == '\r' || source[i] == '\t') {
			if(source[i] == ' ' || source[i] == '\t')
				state->col++;
			if(source[i] == ' ' && state->buffsize > 0) {
				if(state->buffer[0] != '"') {
					continue;
				}
			} else {
				continue;
			}
		}
		incbuffer(source[i]);
		bool success = false;
		char * recentname = NULL;
		for(j = 0 ; j < state->npatterns; j++){
			if(strcmp(state->patterns[j].name,"Symbol") == 0) {
				if((source[i] == '/' && source[i+1] == '*') || (source[i] == '*' && (source[i-1] == '/' || source[i+1] == '/'))) {
					break;
				}
			}
			if(isvalid(state->patterns[j].regex, state->buffer)){
				recentname = state->patterns[j].name;
				success = true;
				break;
			}
		}	
		while(success){
			if(i == strlen(source) - 1){
				if(recentname != NULL){
					if(strcmp(recentname,"Comment") != 0) {
						releasetoken(recentname);
					}
				}
				resetbuffer();
				break;
			}
			incbuffer(source[++i]);
			success = false;
			for(j = 0 ; j < state->npatterns ; j++){
				if(isvalid(state->patterns[j].regex, state->buffer)){
					recentname = state->patterns[j].name;
					success = true;
				}
			}
			if(!success){
				state->start_line = state->line;
				state->start_col = state->col;
				i--;
				decbuffer();
				if(strcmp(recentname,"Comment") != 0) {
					releasetoken(recentname);
				}
				resetbuffer();
				break;
			}
		}
	}
}

static void addtoken(char * tokenpattern, char * tokenname){
	pattern_t tmp  = {.name = tokenname, .regex = tokenpattern};
	state->patterns[state->npatterns++] = tmp;
}

static void releasetoken(const char * typename_){
	state->tokens = (token_t*)realloc(state->tokens, (sizeof(token_t)*(state->ntokens+1)));
	token_t tmp = {.type = (char*)typename_, .str = state->buffer};
	state->tokens[state->ntokens++] = tmp;
}

static void incbuffer(const char c){
	if(c == '\n') {
		state->line++;
		state->prev_col = state->col;
		state->col = 0;
	} else {
		state->col++;
	}
	state->buffer = (char*)realloc(state->buffer, (state->buffsize+2));
	state->buffer[state->buffsize++] = c;
	state->buffer[state->buffsize] = '\0';
}

static void decbuffer(void){
	if(state->buffsize != 0) {
		if(state->buffer[state->buffsize-1] == '\n') {
			state->line--;
			state->col = state->prev_col;
		} else {
			state->col--;
		}
		state->buffer = (char*)realloc(state->buffer, (state->buffsize-1));
		state->buffsize--;
		state->buffer[state->buffsize] = '\0';
	}
}

static void resetbuffer(void){
	state->buffer = (char*)malloc(1);
	state->buffsize = 0;
}

static bool isvalid(const char * pattern, const char * target){
	regcomp(state->obj, pattern, REG_EXTENDED);
	regmatch_t * matches = (regmatch_t*)malloc(sizeof(regmatch_t) * MAX_NUM_MATCHES);
	if(regexec(state->obj, target, MAX_NUM_MATCHES, matches, 0) != 0){
		free(matches);
		return false;
	}
	const unsigned int len = strlen(target);
	int i;
	for(i = 0 ; i < MAX_NUM_MATCHES ; i++){
		if(matches[i].rm_so == 0 && matches[i].rm_eo == len && matches[i].rm_eo != 0){
			free(matches);
			return true;
		} else if (matches[i].rm_so == -1){
			break;
		}
	}
	free(matches);
	return false;
}

static void initstateconfig(bool new_){
	if(new_){
		state = (struct state_t*)malloc(sizeof(struct state_t));
		state->obj = (regex_t*)malloc(sizeof(regex_t));
		state->patterns = (pattern_t*)malloc(sizeof(pattern_t)*MAX_NUM_PATTERNS);
		state->tokens = (token_t*)malloc(1);
		state->ntokens = 0;
		state->npatterns = 0;
		state->buffsize = 0;
		state->buffer = (char*)malloc(1);
		state->line = 1;
		state->col = 0;
		state->start_line = 1;
		state->start_col = 0;
	}
}
#endif