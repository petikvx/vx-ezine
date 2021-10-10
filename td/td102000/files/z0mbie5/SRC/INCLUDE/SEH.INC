
seh_init_nodebugmsg     macro
                        call    __seh_init      ; install seh
                        mov     esp, [esp+8]
                        jmp     __seh_error
__seh_init:             xor     eax, eax
                        push    dword ptr fs:[eax]
                        mov     fs:[eax], esp
                        endm

seh_init                macro
                        debugmsg sehinit
                        call    __seh_init      ; install seh
                        mov     esp, [esp+8]
                        debugmsg seherror
                        jmp     __seh_error
__seh_init:             xor     eax, eax
                        push    dword ptr fs:[eax]
                        mov     fs:[eax], esp
                        endm

seh_done_nolab          macro                   ; uninstall seh
                        pop     dword ptr fs:[0]
                        pop     eax
                        debugmsg sehdone
                        endm

seh_done_nodebugmsg     macro                   ; uninstall seh
__seh_error:            pop     dword ptr fs:[0]
                        pop     eax
                        endm

seh_done                macro                   ; uninstall seh
                        seh_done_nodebugmsg
                        debugmsg sehdone
                        endm
