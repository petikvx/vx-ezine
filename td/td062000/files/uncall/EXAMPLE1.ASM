
; EXAMPLE of using UNCALL.INC
;
; action:
; - enter ring-0;
; - produce some VxDcall;
; - call 'uncall_range' subroutine, so all vxdcalls in program will be
;   returned back into 'CD 20 xxxx yyyy' state.

include                 consts.inc

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

ring0:
                        int 3

                        VxDcall 000Bh,0001h ; VSD_Bell

                        lea     esi, start
                        mov     ecx, virsize
                        call    uncall_range

                        ret

include                 ring0.inc
include                 uncall.inc

virsize                 equ     $-start

                        end     start
