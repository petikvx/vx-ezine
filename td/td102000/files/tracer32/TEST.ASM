
; þ the program to generate an EXCEPTION
; þ in the new created thread
; þ under SEH (i.e. handle it)
; þ tracer32 will show you all the opcodes traced

; soft-ice && i3here on  -- tracer32 doesn't works

include                 consts.inc

callW                   macro   x
                        extern  x:PROC
                        call    x
                        endm

                        p386
                        model   flat
                        locals  __
                        jumps

                        .data

                        dd      ?

                        .code
start:
                        lea     esi, start
                        mov     edi, esi
                        mov     ecx, 4096
                        rep     cmpsb     ; tracer32 skips it

                        push    eax
                        push    esp ; ThreadId ptr
                        push    0   ; flags
                        push    12345678h
                        push    offset thread
                        push    0 ; stack size. 0==same as in primary thread
                        push    0
                        callW   CreateThread
                        pop     eax

                        push    1000
                        callW   Sleep

                        push    -1
                        callW   ExitProcess

thread:                 push    ebp     ; 'coz EBP __MUST_BE_PRESERVED__

                        call    __seh_init
                        mov     esp, [esp+8]
                        jmp     __seh_error
__seh_init:             push    dword ptr fs:[0]
                        mov     fs:[0], esp

                        xor     eax, eax
                        div     eax

__seh_error:            pop     dword ptr fs:[0]
                        pop     eax

                        pop     ebp
                        retn

                        end     start
