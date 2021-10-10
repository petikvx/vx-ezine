
; PAGETABLE finder library (works under win9X+SoftICE only!)
; see also related article in pagetbl.html
; (x) 2000 Z0MBiE, http://z0mbie.cjb.net

PAGETABLE_MIN           equ     0C0000000h      ; pagetable search range
PAGETABLE_MAX           equ     0D0000000h

PAGEFLAG_P              equ     1               ; P    1=present
PAGEFLAG_RW             equ     2               ; R/W  1=readwrite 0=readonly
PAGEFLAG_US             equ     4               ; U/S  1=user 0=supervisor

; input:  ESI=address
; output: CF=0  EDI=pointer to DWORD in the pagetable (see also PAGEFLAG_xxx)
;         CF=1  not found

find_pagetable_dword:   pusha
                        sub     esp, 4096

                        mov     ebp, esi
                        and     esi, 0FFC00000h      ; ~(4MB-1)

                        sub     ebp, esi

                        lea     ebx, [esi+400000h]   ; 4MB

                        mov     edi, esp
                        cld

__maketbl:

                        push    4096
                        push    esi
                        callW   IsBadReadPtr

                        xor     eax, 1      ; 0<-->1
                        shl     eax, 2      ; 1-->PAGEFLAG_US

                        push    eax

                        push    4096
                        push    esi
                        callW   IsBadWritePtr

                        xor     eax, 1      ; 0<-->1
                        shl     eax, 1      ; 1-->PAGEFLAG_RW

                        or      eax, [esp]
                        stosd

                        pop     eax

                        add     esi, 4096
                        cmp     esi, ebx
                        jne     __maketbl

                        mov     ebx, PAGETABLE_MIN
__cycle:
                        pusha
                        call    __seh_init      ; install seh
__seh_error:            mov     esp, [esp+8]
                        stc
                        jmp     __seh_exit
__seh_init:             push    dword ptr fs:[0]
                        mov     fs:[0], esp
                        mov     eax, [ebx]
                        mov     [ebx], eax
                        clc
__seh_exit:             pop     dword ptr fs:[0]; uninstall seh
                        pop     eax
                        popa
                        jc      __nextpage

;                       push    4096
;                       push    ebx
;                       callW   IsBadWritePtr
;                       or      eax, eax
;                       jnz     __nextpage

                        xor     edi, edi

__scan:                 mov     eax, [ebx+edi]
                        and     eax, PAGEFLAG_US+PAGEFLAG_RW
                        cmp     eax, [esp+edi]
                        jnz     __nextpage
__cont:                 add     edi, 4
                        cmp     edi, 4096
                        jb      __scan

__found:
                        shr     ebp, 10
                        lea     edi, [ebp+ebx]

                        clc
                        jmp     __quit

__nextpage:             add     ebx, 4096
                        cmp     ebx, PAGETABLE_MAX
                        jb      __cycle

                        xor     edi, edi
                        stc

__quit:                 lea     esp, [esp+4096]

                        mov     [esp], edi            ; output: EDI
                        popa
                        ret

