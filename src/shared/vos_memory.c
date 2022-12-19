#include <vos_memory.h>

void* vos_memset(void* s, int c, uintptr_t sz) {
  uintptr_t* p = (uintptr_t*)s;
  uintptr_t x = c & 0xff;
  int i;
  for (i = 3; (1 << i) < sizeof(uintptr_t); ++i) x |= x << (1 << i);
  sz >>= i - 3;
  while (sz--) *p++ = x;
  return s;
}

void* vos_memcpy(void* s, void* d, uintptr_t n) {
  int i;
  for (i = 0; i < n; i++) {
    ((uint8_t*)d)[i] = ((uint8_t*)s)[i];
  }
  return d;
}