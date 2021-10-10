
; EXAMPLE of inverting DWORD at BFF70000 - via modifying pagetable
; (x) 2000 Z0MBiE

callW                   macro   x
                        extern  x:PROC
                        call    x
                        endm

                        p386
                        model   flat
                        locals  __
                        jumps

                        .data

KERNEL@ORD0             dd      0BFF713D4h
msg_1                   db      'inverting DWORD at BFF70000',13,10,0
msg_2                   db      'success, current dword=',0

                        .code
start:
                        lea     edx, msg_1
                        call    dump_asciiz

                        mov     esi, 0BFF70000H
                        call    get_pagetable_entry

                        or      dword ptr [edi], 2  ; PAGEFLAG_RW

                        not     dword ptr [esi] ; пишем в кернел

                        and     dword ptr [edi], not 2

                        lea     edx, msg_2
                        call    dump_asciiz
                        mov     eax, [esi]
                        call    dump_hexdword
                        call    dump_crlf

                        push    -1
                        callW   ExitProcess

include                 console.inc     ; console io

; subroutine: get_cr3
; output:     EBX=CR3

get_cr3:                push    eax

                        sgdt    [esp-6]
                        mov     ebx, [esp-4]    ; EBX<--GDT.base

; кстати, интересная фича: подается AX, а меняется EAX
                        str     ax              ; EAX<--TSS selector
                        and     eax, 0FFF8h     ; <--это может быть убрано

                        add     ebx, eax        ; EBX<--TSS descriptor offset

                        mov     ah, [ebx+7]     ; EAX<--TSS linear address
                        mov     al, [ebx+4]
                        shl     eax, 16
                        mov     ax, [ebx+2]

                        mov     ebx, [eax+1Ch]  ; EBX<--CR3
                        and     ebx, 0FFFFF000h ; EBX<--pagetable phys. offs

                        pop     eax
                        ret

; subroutine: phys2linear
; input:      EBX=physical address
; output:     EBX=linear address

phys2linear:            pusha

                        movzx   ecx, bx         ; BX:CX<--EBX=phys addr
                        shr     ebx, 16

                        mov     eax, 0800h      ; physical address mapping

                        xor     esi, esi        ; SI:DI=size (1 byte)
                        xor     edi, edi
                        inc     edi

                        push    ecx
                        push    eax
                        push    0002A0029h      ; INT 31 (DPMI services)
                        call    KERNEL@ORD0

                        shl     ebx, 16         ; EBX<--BX:CX=linear address
                        or      ebx, ecx

                        mov     [esp+4*4], ebx  ; popa.ebx

                        popa
                        ret

; subroutine: get_pagetable_entry
; input:      ESI=address
; output:     EDI=pagetable entry address

get_pagetable_entry:    pusha

                        call    get_cr3         ; получаем CR3
                        and     ebx, 0FFFFF000h ; EBX<--физ. адрес каталога

                        call    phys2linear     ; получаем линейный адрес

                        mov     eax, esi
                        and     eax, 0FFC00000h
                        sub     esi, eax
                        shr     eax, 20       ; EAX<--адр.эл-та 1го уровня
                        shr     esi, 10       ; ESI<--адр.эл-та 2го уровня

                        mov     ebx, [ebx+eax]  ; EBX<--физ.адрес нужной
                        and     ebx, 0FFFFF000h ; страницы

                        call    phys2linear   ; EBX<--линейный адрес

                        add     esi, ebx      ; ESI<--адрес дворда для патча

                        mov     [esp], esi    ; popa.edi
                        popa
                        ret

                        end     start
