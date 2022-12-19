#include <vos_ctype.h>

const unsigned short _ctype[] = {
    _C,       _C,      _C,       _C,      _C,
    _C,       _C,      _C,       _C,      _C | _S | _HT,
    _C | _S,  _C | _S, _C | _S,  _C | _S, _C,
    _C,       _C,      _C,       _C,      _C,
    _C,       _C,      _C,       _C,      _C,
    _C,       _C,      _C,       _C,      _C,
    _C,       _C,      _S | _SP, _P,      _P,
    _P,       _P,      _P,       _P,      _P,
    _P,       _P,      _P,       _P,      _P,
    _P,       _P,      _P,       _D,      _D,
    _D,       _D,      _D,       _D,      _D,
    _D,       _D,      _D,       _P,      _P,
    _P,       _P,      _P,       _P,      _P,
    _U | _X,  _U | _X, _U | _X,  _U | _X, _U | _X,
    _U | _X,  _U,      _U,       _U,      _U,
    _U,       _U,      _U,       _U,      _U,
    _U,       _U,      _U,       _U,      _U,
    _U,       _U,      _U,       _U,      _U,
    _U,       _P,      _P,       _P,      _P,
    _P,       _P,      _L | _X,  _L | _X, _L | _X,
    _L | _X,  _L | _X, _L | _X,  _L,      _L,
    _L,       _L,      _L,       _L,      _L,
    _L,       _L,      _L,       _L,      _L,
    _L,       _L,      _L,       _L,      _L,
    _L,       _L,      _L,       _P,      _P,
    _P,       _P,      _C,       0,       0,
    0,        0,       0,        0,       0,
    0,        0,       0,        0,       0,
    0,        0,       0,        0,       0,
    0,        0,       0,        0,       0,
    0,        0,       0,        0,       0,
    0,        0,       0,        0,       0,
    _S | _SP, _P,      _P,       _P,      _P,
    _P,       _P,      _P,       _P,      _P,
    _P,       _P,      _P,       _P,      _P,
    _P,       _P,      _P,       _P,      _P,
    _P,       _P,      _P,       _P,      _P,
    _P,       _P,      _P,       _P,      _P,
    _P,       _P,      _U,       _U,      _U,
    _U,       _U,      _U,       _U,      _U,
    _U,       _U,      _U,       _U,      _U,
    _U,       _U,      _U,       _U,      _U,
    _U,       _U,      _U,       _U,      _U,
    _P,       _U,      _U,       _U,      _U,
    _U,       _U,      _U,       _L,      _L,
    _L,       _L,      _L,       _L,      _L,
    _L,       _L,      _L,       _L,      _L,
    _L,       _L,      _L,       _L,      _L,
    _L,       _L,      _L,       _L,      _L,
    _L,       _L,      _P,       _L,      _L,
    _L,       _L,      _L,       _L,      _L,
    _L};

unsigned char __tolower(unsigned char c) {
  if (isupper(c)) {
    c -= 'A' - 'a';
  }

  return c;
}

unsigned char __toupper(unsigned char c) {
  if (islower(c)) {
    c -= 'a' - 'A';
  }

  return c;
}