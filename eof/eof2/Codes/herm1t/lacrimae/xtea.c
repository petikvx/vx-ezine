#include "config.h"

#ifdef	ENCRYPT_DATA
/* XTEA encryption (c) David Wheeler and Roger Needham */
/* http://en.wikipedia.org/wiki/XTEA */
static void encipher(unsigned long *v, unsigned long *k) {
	unsigned long v0=v[0], v1=v[1], i;
	unsigned long sum=0, delta=ENCRYPT_DELTA;

	for (i = 0; i < ENCRYPT_ROUNDS; i++) {
		v0 += ((v1 << 4 ^ v1 >> 5) + v1) ^ (sum + k[sum & 3]);
		sum += delta;
		v1 += ((v0 << 4 ^ v0 >> 5) + v0) ^ (sum + k[sum>>11 & 3]);
	}
	v[0]=v0; v[1]=v1;
}

static void decipher(unsigned long *v, unsigned long *k) {
	unsigned long v0=v[0], v1=v[1], i;
	unsigned long delta=ENCRYPT_DELTA, sum=delta*ENCRYPT_ROUNDS;

	for(i=0; i < ENCRYPT_ROUNDS; i++) {
		v1 -= ((v0 << 4 ^ v0 >> 5) + v0) ^ (sum + k[sum>>11 & 3]);
		sum -= delta;
		v0 -= ((v1 << 4 ^ v1 >> 5) + v1) ^ (sum + k[sum & 3]);
	}
	v[0]=v0; v[1]=v1;
}
#endif
