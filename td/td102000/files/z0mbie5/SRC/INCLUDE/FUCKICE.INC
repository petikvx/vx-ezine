
; [ring-0]

fuckice:                pusha

                        push    ebx
                        sidt    [esp-2]
                        pop     ebx

                        downgrade __skip1
                        mov     eax, [ebx+01h*8+6-2]      ; int 01h
                        mov     ax, [ebx+01h*8+0]
IFNDEF DEBUG
                        call    fuckint
ENDIF
__skip1:
                        downgrade __skip2
                        mov     eax, [ebx+03h*8+6-2]      ; int 03h
                        mov     ax, [ebx+03h*8+0]
IFNDEF DEBUG
                        call    fuckint
ENDIF
__skip2:
                        popa
                        ret

fuckint:                cmp     byte ptr [eax], 68h     ; softice signature
                        jne     __skip
                        cmp     byte ptr [eax+5], 0E9h  ; -//-
                        jne     __skip
                        mov     byte ptr [eax], 0CFh ; iret
__skip:                 ret
