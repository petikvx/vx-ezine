
rsa_bit                 equ     416

fake                    macro
                        local   __x
                        downgrade __x
                        call    rsa_decrypt
__x:                    endm

rsa_decrypt:            pusha

                        downgrade __exit

xx                      macro   x
                        sub     eax, _oldeax - x
                        stosd
                        _oldeax = x
                        endm
                        lea     edi, rsa_data
                        cld
                        xor     eax, eax
                        _oldeax = 0
                        ;;
                        xx      07DB672F4H      ; x (encrypted text)
                        xx      0D16CAF7DH
                        xx      085AC01A9H
                        xx      091330DE4H
                        xx      02D512293H
                        xx      044F16344H
                        xx      05D472BA8H
                        xx      06743CA72H
                        xx      0095C755AH
                        xx      0A3DE70CDH
                        xx      0FEF2FB26H
                        xx      0D418083EH
                        xx      04E67B294H
                        ;;
                        xx      000000011h      ; e (exponent)
                        push    12
                        pop     ecx
                        xor     eax,eax
                        rep     stosd
                        _oldeax = 0
                        ;;
                        xx      01A2523EDh      ; n (modulus)
                        xx      0AC460BD0h
                        xx      0CD71FE7Eh
                        xx      003A1761Ah
                        xx      0DF17C16Ah
                        xx      0F060FF19h
                        xx      08533C9CEh
                        xx      00029CFFCh
                        xx      0D47AB9C5h
                        xx      07362B425h
                        xx      0646EC6C1h
                        xx      0B2E58AFDh
                        xx      06444C126h

                        downgrade __exit

                        push    offset rsa_x  ; input
                        push    offset rsa_y  ; output
                        push    offset rsa_d  ; d
                        push    offset rsa_n  ; n
                        call    rsa_main

__exit:
                        popa
                        ret

; SECRET.KEY
;rsa_d label dword
;dd 0F6374B13h,0703257A4h,0C90766E8h,004184103h
;dd 02CD369BEh,0678C454Ah,0A42CD7C7h,052E5452Bh
;dd 0CEAE9D40h,0EF24042Eh,042E593EBh,0D67453E8h
;dd 02C3C7354h
