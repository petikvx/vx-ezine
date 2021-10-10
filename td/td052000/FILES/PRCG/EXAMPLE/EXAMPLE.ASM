
callW                   macro   x
                        extern  x:proc
                        call    x
                        endm

                        p386
                        model   flat

                        .data

filename                db      'prcgcode.bin',0

randseed                dd      ?

buf                     db      32768 dup (?)

                        .code
start:
                        call    randomize

                        lea     edx, filename
                        call    fcreate
                        xchg    ebx, eax

                        lea     edi, buf
                        call    prcg_engine

                        mov     edx, edi
                        xchg    ecx, eax
                        call    fwrite

                        call    fclose

                        push    -1
                        callW   ExitProcess

include                 rnd.inc
include                 ..\PRCG\prcg.inc
include                 etg.inc
include                 fioexlow.inc

                        end     start
