
seh_init                macro
                        call    __seh_init
                        mov     esp, [esp+8]
                        jmp     __seh_exit
__seh_init:             push    dword ptr fs:[0]
                        mov     fs:[0], esp
                        endm

seh_done                macro
__seh_exit:             pop     dword ptr fs:[0]
                        pop     eax
                        endm
