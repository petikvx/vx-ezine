
pusho                   macro   abc     ; push offset of the procedure 'abc'
                        local   t
                        call    t
                        jmp     abc
                        t:
                        endm

callW                   macro   x
                        extern  x:PROC
                        call    x
                        endm

                        p386
                        model   flat
                        locals  __
                        jumps

                        .data

randseed                dd      ?

buf_size                dd      ?

buf                     db      65536 dup (?)

                        .code

start:
                        pusho   my_rnd                  ; offset of rnd()
                        push    offset buf              ; output buffer
                        push    size buf                ; max bufsize
                        push    10000                   ; max # of cmds
                        push    offset buf_size         ; resulting bufsize
                        push    REG_EAX+REG_EBX         ; set of dst regs
                        push    REG_ECX+REG_EDX         ; set of src regs
                        push    ETG_ALL-ETG_JMPS        ; set of avail cmds.
                        call    etg_engine

                        mov     eax, buf_size
                        mov     buf[eax], 0C3h

                        int 3
                        call    near ptr buf

                        push    -1
                        callW   ExitProcess

my_rnd:                 mov     eax, randseed
                        imul    eax, 214013
                        add     eax, 2531011
                        mov     randseed, eax
                        shr     eax, 16
                        imul    eax, [esp+4]
                        shr     eax, 16
                        ret

c_start:
include                 ..\ETG\etg.inc
c_size                  equ     $-c_start

db 3 dup (13,10)
db '---------------------------------',13,10
db 'code size = '
db c_size/1000 mod 10+'0'
db c_size/ 100 mod 10+'0'
db c_size/  10 mod 10+'0'
db c_size/   1 mod 10+'0'
db ' byte(s)',13,10
db '---------------------------------',13,10
db 3 dup (13,10)

                        end     start
