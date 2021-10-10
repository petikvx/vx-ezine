
; all import-related stuff is here

calchash                macro   procname
                        hash = 0
                        irpc    c, <procname>
                        hash = ((hash shl 7) and 0FFFFFFFFh) or (hash shr (32-7))
                        hash = hash xor "&c"
                        endm
                        endm

mov_h                   macro   reg, procname
                        calchash procname
                        mov     reg, hash
                        endm

import                  macro   x      ; process one import (x=procname)
                        IF      _q EQ 1
                        mov_h   eax, x  ; calc hash
                        call    edx
                        stosd
                        ELSE
xx&x                    dd      ?
                        ENDIF
                        endm

import_main             macro   q
                        _q      = q
include                 implist.inc
                        endm

init_win32api:          pusha
                        call    get_kernel_export_base
                        pusho   findfunc_caller
                        pop     edx
                        lea     edi, xx_first
                        cld
                        import_main 1
                        popa
                        ret

get_kernel_export_base: mov     ebx, 0BFF70000h
                        mov     ecx, [ebx].mz_neptr
                        mov     ecx, [ecx+ebx].pe_exporttablerva
                        add     ecx, ebx
                        ret

findfunc_caller:        push    edi
                        push    edx
                        xchg    edi, eax
                        call    findfunc
                        pop     edx
                        pop     edi
                        jnz     __ret
                        pop     eax
__ret:                  ret

findfunc:               xor     esi, esi
__search_cycle:         lea     edx, [esi*4+ebx]
                        add     edx, [ecx].ex_namepointersrva
                        mov     edx, [edx]
                        add     edx, ebx
                        xor     eax, eax
__calc_hash:            rol     eax, 7
                        xor     al, [edx]
                        inc     edx
                        cmp     byte ptr [edx], 0
                        jne     __calc_hash
                        cmp     eax, edi
                        je      __name_found
                        inc     esi
                        cmp     esi, [ecx].ex_numofnamepointers
                        jb      __search_cycle
                        xor     eax, eax
                        ret
__name_found:           mov     edx, [ecx].ex_ordinaltablerva
                        add     edx, ebx
                        movzx   edx, word ptr [edx+esi*2]
                        mov     eax, [ecx].ex_addresstablerva
                        add     eax, ebx
                        mov     eax, [eax+edx*4]
                        add     eax, ebx
                        ret

