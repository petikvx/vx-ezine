
; entering ring0 (seh, ldt, callgate)

callring0:              pusha

                        seh_init

                        push    ebx
                        sgdt    [esp-2]
                        pop     ebx

                        sldt    ax
                        and     eax, not 111b
                        jz      __exit

                        add     ebx, eax

                        mov     edi, [ebx]
                        mov     ah, [ebx+7]
                        mov     al, [ebx+4]
                        shrd    edi, eax, 16

                        fild    qword ptr [edi]

                        call    __popaddr

                        pusha
                        push    ds es

                        push    ss ss
                        pop     ds es

                        call    ring0handler

                        pop     es ds
                        popa
                        retf

__popaddr:              pop     eax
                        cld
                        stosd
                        stosd
                        mov     dword ptr [edi-6], 0EC000028h

                        db      9Ah
                        dd      0
                        dw      100b+11b

                        fistp   qword ptr [edi-8]

__exit:
                        seh_done

                        popa
                        ret
