
/* Fatal RANDOMER v2.00  */

#ifndef _INC_WINDOWS
#pragma message ("WINDOWS.H should be #included first.")
#include <windows.h>
#endif

// W=word, but dont need div0-check && 1.5 times faster than rnd()
// R=range, X=div0-check

#define rnd(d)          (random() % (d))                // [0..d-1]
#define rndW(w)         (((random() >> 16) * (w)) >> 16)// [0..w-1]
#define rndR(a,b)       ((a)+rnd((b)-(a)+1))            // [a..b]
#define rndX(d)         ((d)==0?0:rnd(d))               // to avoid div0

DWORD randseed = GetTickCount();                        // randomize sucks

DWORD random()
{
  return randseed = randseed * 0x8088405 + 1;           // TP 7.0
}
