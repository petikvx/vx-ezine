
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

; find function's address in export table
;
; input:  EBX=imagebase va, ECX=export table va, EDI=name csum
; modify: EDX, ESI
; output: ZF=1, EAX=0 (function not found)
;         ZF=0, EAX=function va

findfunc:               xor     esi, esi        ; current index
__search_cycle:         lea     edx, [esi*4+ebx]
                        add     edx, [ecx].ex_namepointersrva
                        mov     edx, [edx]      ; name va
                        add     edx, ebx        ; +imagebase

                        xor     eax, eax        ; calculate hash
__calc_hash:            rol     eax, 7
                        xor     al, [edx]
                        inc     edx
                        cmp     byte ptr [edx], 0
                        jne     __calc_hash

                        cmp     eax, edi        ; compare hashs
                        je      __name_found

                        inc     esi             ; index++
                        cmp     esi, [ecx].ex_numofnamepointers
                        jb      __search_cycle
                        xor     eax, eax        ; return 0
                        ret

__name_found:           mov     edx, [ecx].ex_ordinaltablerva
                        add     edx, ebx        ; +imagebase
                        movzx   edx, word ptr [edx+esi*2]; edx=current ordinal
;                       sub     edx, [ecx].ex_ordinalbase  ; -ordinal base
                        mov     eax, [ecx].ex_addresstablerva
                        add     eax, ebx        ; +imagebase
                        mov     eax, [eax+edx*4]; eax=current address
                        add     eax, ebx        ; +imagebase
                        ret                     ; return address

PROC_ALIGN              equ     65536

find_mz:                and     ebx, not (PROC_ALIGN-1)
                        add     ebx, PROC_ALIGN
__cycle:                sub     ebx, PROC_ALIGN
                        cmp     byte ptr [ebx], 'M'
                        jne     __cycle
                        cmp     byte ptr [ebx+1], 'Z'
                        jne     __cycle
                        ret

get_ex_base:            call    getanykerneladdr
                        call    find_mz
                        mov     ecx, [ebx].mz_neptr     ; ECX=export va
                        mov     ecx, [ecx+ebx].pe_exporttablerva
                        add     ecx, ebx
                        ret

; greetz to u_dev, who published following method at topdevice.cjb.net

getanykerneladdr:       xor     ebx, ebx
                        mov     ebx, fs:[ebx]
__cycle:                cmp     dword ptr [ebx], -1
                        je      __rule
                        mov     ebx, [ebx]
                        jmp     __cycle
__rule:                 mov     ebx, [ebx+4]
                        ret
