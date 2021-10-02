
;------------------------------------------------------------------------------
; RSALIB  v6.01  (x) 2002
;------------------------------------------------------------------------------
; - proudly written in x86 asm
; - about 1.4k code size, slow
; - variable-length keys (on-stack dynamic data allocation)
; - key generation stuff + modexp to encrypt/decrypt
; - doesn't uses data, offset-independent - can be
;   displaced and/or permutated.
;------------------------------------------------------------------------------

USE_MODEXP              equ     YES     ; compilation options --
USE_TESTPRIME           equ     YES     ; -- used if defined
;USE_KEYGEN             equ     YES
;USE_HCRYPTPROV         equ     YES

NP                      equ     200     ; # of primes in primetable

rsalib6_start:

include                 _common.inc     ; common stuff

IFDEF USE_MODEXP
include                 _modexp.inc     ; modexp (slow but small size)
IFDEF USE_TESTPRIME
include                 _testprime.inc  ; bigprime tester (Fermat's theorem)
ENDIF
ENDIF

IFDEF USE_KEYGEN
                        public  _keygen
                        public  keygen

include                 _shortmod.inc   ; bignumber % dword
include                 _shortgcd.inc   ; gcd(bignumber, dword)
include                 _mul.inc        ; bignumber mul
include                 _modinv.inc     ; modular inverse (badly fuckin shit)
include                 _divmod.inc     ; bignumber div & mod
include                 _primetab.inc   ; prime table generator (2,3,5,7,...)
include                 _findprime.inc  ; bigprime finder ('sieve')
include                 _keygen.inc     ; main m/d/e - generator
ENDIF ; USE_KEYGEN

IFDEF   USE_HCRYPTPROV
include                 _random.inc
ENDIF ; USE_HCRYPTPROV

rsalib6_end:
rsalib6_size            equ     rsalib6_end-rsalib6_start
