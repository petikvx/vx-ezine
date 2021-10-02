
#ifndef RSALIB6_HPP
#define RSALIB6_HPP

 // action: generate m,e,d,p,q
extern "C"
void __cdecl keygen( IN           DWORD l,     // length, in BIT's
                     IN  OPTIONAL DWORD rndbuf[], // NULL=use hcryptprov
                     OUT OPTIONAL DWORD m[],   // public modulus (m=p*q)
                     OUT OPTIONAL DWORD e[],   // public exponent
                     OUT OPTIONAL DWORD d[],   // secret exponent
                     OUT OPTIONAL DWORD p[],   // secret prime p
                     OUT OPTIONAL DWORD q[] ); // secret prime q

 // action: x = (a ^ e) % m
extern "C"
void __cdecl modexp( IN  DWORD l,             // length, in BIT's
                     OUT DWORD x[],           // result
                     IN  DWORD a[],           // base
                     IN  DWORD e[],           // exponent
                     IN  DWORD m[] );         // modulus

extern "C"
BOOL __cdecl testprime( IN DWORD l,           // length, in BIT's
                        IN BYTE p[] );        // prime
#endif
