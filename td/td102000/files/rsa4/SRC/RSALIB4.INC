
;----------------------------------------------------------------------------
; RSA-encryption library (KEYGEN+MODEXP)      (x) 2000 Z0MBiE, z0mbie.cjb.net
;----------------------------------------------------------------------------

; version 4.00

; þ key generator added (keygen in asm -- can u imagine it?)
; þ fixed precision (KEYLEN const)
; * warning: some bignumber operation subroutines requires high bits == 0;
;   this means that real key length is less than specified

; comments:
; þ in this stuff were used some algorithms partially taken from:
;   1. pgp 2.6.3i sources: genprime.c, mpilib.c -- good descriptions there
;   2. ..\rsa.cpp, rsa.hpp, vlong.cpp, vlong.hpp -- dunno what is it

;----------------------------------------------------------------------------

KEYLEN                  equ     256             ; key length, BITs

PUBKEYSIZE              equ     KEYLEN/8*2      ; public key size, BYTEs (m/e)
SECKEYSIZE              equ     KEYLEN/8*2      ; secret key size, BYTEs (m/d)
RNDBUFSIZE              equ     KEYLEN/8        ; random buffer size, BYTEs

PRIMELEN                equ     KEYLEN/2        ; KEYLEN/2
NP                      equ     200             ; # of primes in primetable

;----------------------------------------------------------------------------

USE_KEYGEN              equ             SURE, MOTHERFUCKER!
IFDEF                   USE_KEYGEN
include                 _keygen.inc     ; main m/d/e - generator
include                 _genprime.inc   ; prime table generator (2,3,5,7,...)
include                 _findprime.inc  ; bigprime finder ('sieve')
include                 _testprime.inc  ; bigprime tester (Fermat's theorem)
include                 _shortmod.inc   ; bignumber % dword
include                 _shortgcd.inc   ; gcd(bignumber, dword)
include                 _copysub1.inc   ; some shit
include                 _divmod.inc     ; bignumber div & mod
include                 _mul.inc        ; bignumber mul
include                 _modinv.inc     ; modular inverse (badly fuckin shit)
ENDIF
include                 _modexp.inc     ; very fast modexp

;----------------------------------------------------------------------------
