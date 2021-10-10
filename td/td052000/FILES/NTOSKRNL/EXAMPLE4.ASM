
; EXAMPLE of entering RING-0 via INT 2E -- fn. PoCallDriver
; 100% working version

callW                   macro   x
                        extern  x:PROC
                        call    x
                        endm

                        p386
                        model   flat
                        locals  __

                        .data

                        dd      ?

                        .code
start:

                        lea     esi, ring0
                        call    callring0

                        push    -1
                        callW   ExitProcess

ring0:                  int 3
                        ret

include                 ring0.inc

                        end     start
