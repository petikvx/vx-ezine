
; дык, блядь, kme32, не совместимо оказалось с конкретным методом
; заражения файлов.
;
; так что это - просто заглушка.
;
; original kme32 engine: kme32_org.inc (unused)

                        p586

kme_main                proc    pascal

                        ; parameters -- pushed in reversed order
                        arg     i_offs:DWORD    ; virus offset
                        arg     i_size:DWORD    ; virus size
                        arg     i_entry:DWORD   ; virus entry (relative)
                        arg     o_offs:DWORD    ; output offset
                        arg     o_max:DWORD     ; output max buf size
                        arg     o_fillchar:DWORD; character to fill out buf
                        arg     po_size:DWORD   ; pointer to out buf size
                        arg     po_entry:DWORD  ; pointer to out entry (rel.)
                        arg     jmp_prob:DWORD  ; JMPs if rnd(jmp_prob)==0
                        arg     randseed0:DWORD  ; randomer initializer
                        arg     regavail:DWORD  ; register set (REG_XXX)
                        arg     cmdavail:DWORD  ; command set (CMD_XXX)
                        arg     flags:DWORD     ; flags (FLAG_XXX)
                        arg     mapoffs:DWORD  ; map, size=o_max

                        pusha

                        mov     esi, i_offs
                        mov     edi, o_offs
                        mov     ecx, i_size
                        mov     ebx, po_size
                        mov     [ebx], ecx
                        cld
                        rep     movsb
                        mov     eax, i_entry
                        mov     edi, po_entry
                        stosd

                        clc

                        popa                    ; retore regs & exit
                        ret
kme_main                endp
