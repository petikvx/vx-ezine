
; ACTION: enter ring-0 (via INT 2E)

; COMMENT:
;   Sometimes this code generates a BUG, and i dunno how to fix it.(17-05-00)
;   Error is the followin: we're entering ring-0, but page at our ring-0 eip
;   is absent in the current context.

include                 ntoskrnl.inc

callW                   macro   x
                        extern  x:proc
                        call    x
                        endm

                        p386
                        model   flat

                        locals  __

                        .data

r0_finished             db      0
thread_handle           dd      ?

stk:                    dd      offset thread_handle ; 0 or *thread_handle
                        dd      0               ; 0 or 0x1F03FF
                        dd      0               ; 0
                        dd      0               ; 0
                        dd      0               ; 0
                        dd      offset ring0    ; thread EIP, near proc
                        dd      12345678h       ; thread-parameter

;critsect               db      256 dup (?)

                        .code
start:
;                       push    offset critsect
;                       callW   InitializeCriticalSection
;                       push    offset critsect
;                       callW   EnterCriticalSection

                        mov     eax, i2E_PsCreateSystemThread
                        lea     edx, stk
                        int     2Eh

__cycle:                cmp     r0_finished, 1
                        jne     __cycle

;                       push    offset critsect
;                       callW   LeaveCriticalSection
;                       push    offset critsect
;                       callW   DeleteCriticalSection

                        push    -1
                        callW   ExitProcess

; input: [ESP+4]=EDI=thread_parameter

ring0:                  int 3
                        mov     r0_finished, 1
                        ret

                        end     start
