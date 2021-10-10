
seh_init                macro
                        call    __seh_init
                        mov     esp, [esp+8]
                        stc
                        jmp     __seh_error
__seh_init:             xor     eax, eax
                        push    dword ptr fs:[eax]
                        mov     fs:[eax], esp
                        endm

seh_done                macro
__seh_error:            pop     dword ptr fs:[0]
                        pop     eax
                        endm
