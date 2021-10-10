
ii                      equ     0Dh

intii:                  db      0eah
                        dd      $+4+2
                        dw      28h

                        lea     esi, idt_descriptor_saved onstack
                        mov     edi, idt_base onstack
                        add     edi, ii*8
                        cld
                        movsd
                        movsd

                        lea     esi, gdt_descriptor_saved onstack
                        mov     edi, gdt_base onstack
                        add     edi, selector onstack
                        movsd
                        movsd

                        call    ring0_code

                        iret

