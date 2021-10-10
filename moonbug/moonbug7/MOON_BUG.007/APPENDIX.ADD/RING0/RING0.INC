
init_ring0:             sgdt    gdtr onstack
                        sidt    idtr onstack

                        cld

                        movzx   eax, word ptr (gdt_limit onstack)
                        sub     eax, 7
                        mov     selector onstack, eax

                        mov     esi, gdt_base onstack
                        add     esi, selector onstack
                        lea     edi, gdt_descriptor_saved onstack
                        movsd
                        movsd

                        mov     edi, gdt_base onstack
                        add     edi, selector onstack

;               2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
;31             4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7            0
;---------------------------------------------------------------
;|               | | | |A|      | | D | |      |               |
;| BASE  31:24   |G|D|0|V|      |P| P |S| TYPE |   BASE 23:16  |
;|               | | | |L|      | | L | |      |               |
;|-------------------------------------------------------------|
;|         BASE       15:00     |          LIMIT      15:00    |
;---------------------------------------------------------------

gdt_desc_limit          equ     4096-1
gdt_desc_base           equ     offset page2

                        ; G      0    no granularity
                        ; D      1    32-bit
                        ; AVL    0    used by soft
                        ; P      1    segment present
                        ; DPL    00   ring 0
                        ; S      1    normal segment (0 = system)
                        ;        CRA
                        ; TYPE   011  read/exec

gdt_desc_type           equ     0100000010011011b

                       ;dw      gdt_desc_limit
                       ;dw      gdt_desc_base and 65535
                       ;db      gdt_desc_base shr 16 and 255
                       ;dw      gdt_desc_type
                       ;db      gdt_desc_base shr 24 and 255

                        mov     ax, gdt_desc_limit
                        stosw
                        mov     eax, base onstack
                        add     eax, gdt_desc_base
                        stosw
                        shr     eax, 16
                        stosb
                        push    ax
                        mov     ax, gdt_desc_type
                        stosw
                        pop     ax
                        shr     ax, 8
                        stosb

                        mov     esi, idt_base onstack
                        add     esi, ii*8
                        lea     edi, idt_descriptor_saved onstack
                        movsd
                        movsd

                        mov     edi, idt_base onstack
                        add     edi, ii*8

;               2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
;31             4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4      0
;------------------------------------------------------------------
;|                               | | D |         |     |          |
;|           RESERVED            |P| P |0 1 1 1 0|0 0 0| RESERVED | +4
;|                               | | L |         |     |          |
;|----------------------------------------------------------------|
;|       SEGMENT SELECTOR        |         OFFSET  15:00          | +0
;------------------------------------------------------------------

idt_desc_offs           equ     intii-page2
idt_desc_selector       equ     <word ptr (selector onstack)>

                        ; P      1      segment present
                        ; DPL    11     ring 3
                        ;        01110  const

idt_desc_type           equ     11101110b

                       ;dw      idt_desc_offs
                       ;dw      idt_desc_selector
                       ;db      0                 ; reserved
                       ;db      idt_desc_type
                       ;dw      0                 ; reserved

                        mov     ax, idt_desc_offs
                        stosw
                        mov     ax, idt_desc_selector
                        stosw
                        xor     ax, ax
                        stosb
                        mov     al, idt_desc_type
                        stosb
                        xor     ax, ax
                        stosw

                        ret

