
; greetz to GreenMonster, who published idea at topdevice.cjb.net

LDT_MIN_ADDR            equ     080000000h
LDT_MAX_ADDR            equ     0FFFFF000h
LDT_SCANSIZE            equ     4096

; subroutine: find_ldt_prepare
; action:     fill internal variables
; output:     CF=0 all ok
;             CF=1 unknown error

find_ldt_prepare:       pusha

                        xor     esi, esi

__cycle:                lea     eax, ldtpage[esi]
                        push    eax
                        lea     eax, [esi+4]  ; bit2=LDT
                        push    eax
                        call    xxGetCurrentThread
                        push    eax
                        call    xxGetThreadSelectorEntry
                        or      eax, eax
                        jz      __error

                        add     esi, 8
                        cmp     esi, LDT_SCANSIZE
                        jb      __cycle

                        clc

__exit:                 popa
                        ret

__error:                stc
                        jmp     __exit

; subroutine: find_ldt_scanmemory
; input:      none
; output:     CF=0   EBX=LDT base
;             CF=1   not found

find_ldt_scanmemory:    mov     ebx, LDT_MIN_ADDR

__cycle:                call    find_ldt_testpage
                        jnc     __found

                        add     ebx, 4096
                        cmp     ebx, LDT_MAX_ADDR
                        jb      __cycle

                        stc
                        ret

__found:                clc
                        ret

; subroutine: find_ldt_testpage
; input:      EBX=any VA
; output:     CF=0  address contains LDT
;             CF=1  no ldt found or an error occured while accessing memory

find_ldt_testpage:      pusha

                        call    __seh_init
                        mov     esp, [esp+8]
__error:                stc
                        jmp     __seh_exit
__seh_init:             push    dword ptr fs:[0]
                        mov     fs:[0], esp

                        or      byte ptr [ebx], 0       ; must be writeable

                        lea     esi, ldtpage
                        mov     edi, ebx
                        mov     ecx, LDT_SCANSIZE/4
                        cld
                        rep     cmpsd
                        jne     __error

                        clc

__seh_exit:             pop     dword ptr fs:[0]
                        pop     eax

                        popa
                        ret

; ---------------------------------------------------------------------------

find_ldt_via_gdt:       push    ebx
                        sgdt    [esp-2]
                        pop     ebx

                        sldt    ax
                        and     eax, not 111b

                        add     eax, ebx

                        mov     bh, [eax+7]
                        mov     bl, [eax+4]
                        shl     ebx, 16
                        mov     bx, [eax+2]

                        ret
