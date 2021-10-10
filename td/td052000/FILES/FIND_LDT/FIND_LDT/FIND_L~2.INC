
; greetz to GreenMonster, who published idea at topdevice.cjb.net

LDT_MIN_ADDR            equ     080000000h
LDT_MAX_ADDR            equ     0FFFFF000h

                        .data

cs_descr                dd      ?,?
ds_descr                dd      ?,?
fs_descr                dd      ?,?

                        .code

; subroutine: find_ldt_prepare
; action:     fill internal variables
; output:     CF=0 all ok
;             CF=1 unknown error

find_ldt_prepare:       pusha

                        callW   GetCurrentThread
                        xchg    ebx, eax

                        push    offset cs_descr
                        push    cs
                        push    ebx
                        callW   GetThreadSelectorEntry
                        or      eax, eax
                        jz      __error

                        push    offset ds_descr
                        push    ds
                        push    ebx
                        callW   GetThreadSelectorEntry
                        or      eax, eax
                        jz      __error

                        push    offset fs_descr
                        push    fs
                        push    ebx
                        callW   GetThreadSelectorEntry
                        or      eax, eax
                        jz      __error

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

                        mov     ecx, cs
                        and     ecx, not 7
                        mov     eax, [ebx+ecx]
                        cmp     eax, cs_descr
                        jne     __error
                        mov     eax, [ebx+ecx+4]
                        cmp     eax, cs_descr+4
                        jne     __error

                        mov     ecx, ds
                        and     ecx, not 7
                        mov     eax, [ebx+ecx]
                        cmp     eax, ds_descr
                        jne     __error
                        mov     eax, [ebx+ecx+4]
                        cmp     eax, ds_descr+4
                        jne     __error

                        mov     ecx, fs
                        and     ecx, not 7
                        mov     eax, [ebx+ecx]
                        cmp     eax, fs_descr
                        jne     __error
                        mov     eax, [ebx+ecx+4]
                        cmp     eax, fs_descr+4
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
