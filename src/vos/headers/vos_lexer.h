#pragma once
#include <cvector.h>

enum TokenType {
    
}

typedef struct
{
  TokenType type;

  // The beginning of the token, pointing directly into the source.
  const char* start;

  // The length of the token in characters.
  int length;

  // The 1-based line where the token appears.
  int line;
  
  // The parsed value if the token is a literal.
  Value value;
} Token;