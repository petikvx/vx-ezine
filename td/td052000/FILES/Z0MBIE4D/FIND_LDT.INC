
; greetz to GreenMonster, who published following idea at topdevice.cjb.net

find_ldt_scanmemory:    mov     ebx, 80000000h

__cycle:                add     ebx, 4096
                        jz      __exit_sux
                        call    find_ldt_testpage
                        jc      __cycle

                        clc
                        ret

__exit_sux:             stc
                        ret

find_ldt_testpage:      push    ebx

                        call    __seh_init
                        mov     esp, [esp+8]
                        jmp     __exit_sux
__seh_init:             xor     ecx, ecx
                        push    dword ptr fs:[ecx]
                        mov     fs:[ecx], esp

                        ; CS: ff ff 00 00 00 fb cf 00
                        ; DS: ff ff 00 00 00 f7 40 00
                        ; FS: 37 00 xx xx xx f3 00 xx

                        cmp     [ebx].dword ptr 0, ecx
                        jne     __exit_sux
                        cmp     [ebx].dword ptr 4, ecx
                        jne     __exit_sux

                        mov     eax, cs
                        and     eax, not 7

                        cmp     [ebx+eax].dword ptr 0, 0000FFFFh
                        jne     __exit_sux
                        cmp     [ebx+eax].dword ptr 4, 00CFFB00h
                        jne     __exit_sux

                        mov     eax, ds
                        and     eax, not 7

                        cmp     [ebx+eax].dword ptr 0, 0000FFFFh
                        jne     __exit_sux
                        cmp     [ebx+eax].dword ptr 4, 0040F700h
                        jne     __exit_sux

                        mov     eax, fs
                        and     eax, not 7

                        cmp     [ebx+eax].word ptr 0, 0037h
                        jne     __exit_sux
                        cmp     [ebx+eax].word ptr 5, 00F3h
                        jne     __exit_sux

                        clc
                        jmp     __exit

__exit_sux:             stc

__exit:                 pop     dword ptr fs:[0]
                        pop     eax

                        pop     ebx
                        ret
