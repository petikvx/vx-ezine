xor_loop:
        lodsw                                   ; load word from si into ax
                                                ; and increment si by one

        jnc     false_jump                      ; anti-heuristic, really jmp

false_jump_2:
        stosw                                   ; load word from ax into di
                                                ; and increment di by one
        loop    xor_loop                        ; loop until finished
        ret                                     ; return to calling address

false_jump:
        db      35h                             ; db for xor ax, word value

        jnc     false_jump_2                    ; anti-heuristic, really jmp

        ret