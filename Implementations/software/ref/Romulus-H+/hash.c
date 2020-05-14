#include "skinny.h"
#include <stdio.h>
#include <stdlib.h>

void hirose_128_128_256 (unsigned char* h,
			 unsigned char* g,
			 const unsigned char* m) {
  unsigned char key [48];
  unsigned char hh  [16];
  int i;

  for (i = 0; i < 16; i++) { // assign the key for the
                             // hirose compresison function
    key[i] = g[i];
    g[i]   = h[i];
    hh[i]  = h[i];
  }
  g[0] ^= 0x01;
  for (i = 0; i < 32; i++) {
    key[i+16] = m[i];
  }
  
  skinny_128_384_plus_enc(h,key);
  skinny_128_384_plus_enc(g,key);

  for (i = 0; i < 16; i++) {
    h[i] ^= hh[i];
    g[i] ^= hh[i];
  }
  g[0] ^= 0x01;
  
}

void initialize (unsigned char* h,
		 unsigned char* g) {
  unsigned char i;

  for (i = 0; i < 16; i++) {
    h[i] = 0;
    g[i] = 0;
  }
}

// Pad an additional block
void pad2 (const unsigned char* m,
	   unsigned char* p,
	   unsigned long long mlen) {
  unsigned char i;

  for (i = 0; i < 24; i++) { 
    p[i] = 0;
  }
  for (i = 24; i < 32; i++) {
    p[i] = (mlen>>(32-i))%256;
  }

}

unsigned char pad (const unsigned char* m,
		   unsigned char* p,
		   unsigned long long mlen) {
  unsigned char i;

  if ((mlen%32) == 0) { // If the message is a multiple of 32 bytes
    for (i = 0; i < 24; i++) {
      p[i] = 0;
    }
    for (i = 24; i < 32; i++) {
      (mlen>>(32-i))%256;
    }
  }
  else if ((mlen%32) <= 24) { // If padding can fit in one block
    for (i = 0; i < mlen; i++) {
      p[i] = m[i];
    }
    for (i = mlen; i < 24; i++) {
      p[i] = 0;
    }
    for (i = 24; i < 31; i++) {
      (mlen>>(32-i))%256;
    }
    return 0;
  }
  else { // If padding needs an extra block
    for (i = 0; i < (mlen%32); i++) {
      p[i] = m[i];
    }
    for (i = (mlen%32); i < 32; i++) {
      p[i] = 0;
    }
    return 1;
  }
  
}

int crypto_hash(
unsigned char *out,
const unsigned char *in,
unsigned long long inlen
)
{
  unsigned char h[16];
  unsigned char g[16];
  unsigned long long mlen;
  unsigned char p[32];
  unsigned char d;
  unsigned char i;

  mlen = inlen;

  initialize(h,g);
  while (mlen >= 32) { // Normal loop
    hirose_128_128_256(h,g,in);
    in += 32;
    mlen -= 32;
  }
  d = pad(in,p,inlen); // padding
  if (d == 0) { // Check if padding succeeded in one iteration
    h[0] ^= 2;
    hirose_128_128_256(h,g,p);
  }
  else { // If not, pad into another call
    hirose_128_128_256(h,g,p);
    pad2(in,p,inlen);
    h[0] ^= 2;
    hirose_128_128_256(h,g,p);    
  }
  
  for (i = 0; i < 16; i++) { // Assign the output tag
    out[i] = h[i];
    out[i+16] = g[i];
  }
}


int main () {
}
