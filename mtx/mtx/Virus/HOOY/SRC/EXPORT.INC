
calchash                macro   procname
                        hash = 0
                        irpc    c, <procname>
                        ; rol 7
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

        hooy
findfunc:               xor     esi, esi        ; current index
        hooy
search_cycle:           lea     edx, [esi*4+ebx]
        hooy
                        add     edx, [ecx].ex_namepointersrva
        hooy
                        mov     edx, [edx]      ; name va
        hooy
                        add     edx, ebx        ; +imagebase
        hooy

                        xor     eax, eax        ; calculate hash
        hooy
calc_hash:              rol     eax, 7
        hooy
                        xor     al, [edx]
        hooy
                        inc     edx
        hooy
                        cmp     byte ptr [edx], 0
        hooy
                        jne     calc_hash

        hooy
                        cmp     eax, edi        ; compare hashs
        hooy
                        je      name_found
        hooy

                        inc     esi             ; index++
        hooy
                        cmp     esi, [ecx].ex_numofnamepointers
        hooy
                        jb      search_cycle
        hooy
        hooy
                        xor     eax, eax        ; return 0
        hooy
                        ret
        hooy
        hooy

name_found:             mov     edx, [ecx].ex_ordinaltablerva
        hooy
                        add     edx, ebx        ; +imagebase
        hooy
                        movzx   edx, word ptr [edx+esi*2]; edx=current ordinal
        hooy
;                       sub     edx, [ecx].ex_ordinalbase  ; -ordinal base
        hooy
                        mov     eax, [ecx].ex_addresstablerva
        hooy
                        add     eax, ebx        ; +imagebase
        hooy
                        mov     eax, [eax+edx*4]; eax=current address
        hooy
                        add     eax, ebx        ; +imagebase
        hooy
                        ret                     ; return address
        hooy
