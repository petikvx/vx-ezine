; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³ (c) Lord Julus - 2000		 Vxtasy #1 - Magazine source code ³
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

; wait for keys

check_for_key proc near

cmp cs:keys[kSPACE     ], 1
je setkspace
cmp cs:keys[kA	       ], 1
je setka
cmp cs:keys[kB	       ], 1
je setkb
cmp cs:keys[kC	       ], 1
je setkc
cmp cs:keys[kD	       ], 1
je setkd
cmp cs:keys[kE	       ], 1
je setke
cmp cs:keys[kF	       ], 1
je setkf
cmp cs:keys[kG	       ], 1
je setkg
cmp cs:keys[kH	       ], 1
je setkh
cmp cs:keys[kI	       ], 1
je setki
cmp cs:keys[kJ	       ], 1
je setkj
cmp cs:keys[kK	       ], 1
je setkk
cmp cs:keys[kL	       ], 1
je setkl
cmp cs:keys[kM	       ], 1
je setkm
cmp cs:keys[kN	       ], 1
je setkn
cmp cs:keys[kO	       ], 1
je setko
cmp cs:keys[kP	       ], 1
je setkp
cmp cs:keys[kQ	       ], 1
je setkq
cmp cs:keys[kR	       ], 1
je setkr
cmp cs:keys[kS	       ], 1
je setks
cmp cs:keys[kT	       ], 1
je setkt
cmp cs:keys[kU	       ], 1
je setku
cmp cs:keys[kV	       ], 1
je setkv
cmp cs:keys[kW	       ], 1
je setkw
cmp cs:keys[kX	       ], 1
je setkx
cmp cs:keys[kY	       ], 1
je setky
cmp cs:keys[kZ	       ], 1
je setkz
cmp cs:keys[k1	       ], 1
je setk1
cmp cs:keys[k2	       ], 1
je setk2
cmp cs:keys[k3	       ], 1
je setk3
cmp cs:keys[k4	       ], 1
je setk4
cmp cs:keys[k5	       ], 1
je setk5
cmp cs:keys[k6	       ], 1
je setk6
cmp cs:keys[k7	       ], 1
je setk7
cmp cs:keys[k8	       ], 1
je setk8
cmp cs:keys[k9	       ], 1
je setk9
cmp cs:keys[k0	       ], 1
je setk0
mov al, 0
jmp check_for_key_exit

setkspace:
mov cs:keys[kSPACE     ], 0
mov al, ' '
jmp check_for_key_exit
setka:
mov cs:keys[kA	       ], 0
mov al, 'A'
jmp check_for_key_exit
setkb:
mov cs:keys[kB	       ], 0
mov al, 'B'
jmp check_for_key_exit
setkc:
mov cs:keys[kC	       ], 0
mov al, 'C'
jmp check_for_key_exit
setkd:
mov cs:keys[kD	       ], 0
mov al, 'D'
jmp check_for_key_exit
setke:
mov cs:keys[kE	       ], 0
mov al, 'E'
jmp check_for_key_exit
setkf:
mov cs:keys[kF	       ], 0
mov al, 'F'
jmp check_for_key_exit
setkg:
mov cs:keys[kG	       ], 0
mov al, 'G'
jmp check_for_key_exit
setkh:
mov cs:keys[kH	       ], 0
mov al, 'H'
jmp check_for_key_exit
setki:
mov cs:keys[kI	       ], 0
mov al, 'I'
jmp check_for_key_exit
setkj:
mov cs:keys[kJ	       ], 0
mov al, 'J'
jmp check_for_key_exit
setkk:
mov cs:keys[kK	       ], 0
mov al, 'K'
jmp check_for_key_exit
setkl:
mov cs:keys[kL	       ], 0
mov al, 'L'
jmp check_for_key_exit
setkm:
mov cs:keys[kM	       ], 0
mov al, 'M'
jmp check_for_key_exit
setkn:
mov cs:keys[kN	       ], 0
mov al, 'N'
jmp check_for_key_exit
setko:
mov cs:keys[kO	       ], 0
mov al, 'O'
jmp check_for_key_exit
setkp:
mov cs:keys[kP	       ], 0
mov al, 'P'
jmp check_for_key_exit
setkq:
mov cs:keys[kQ	       ], 0
mov al, 'Q'
jmp check_for_key_exit
setkr:
mov cs:keys[kR	       ], 0
mov al, 'R'
jmp check_for_key_exit
setks:
mov cs:keys[kS	       ], 0
mov al, 'S'
jmp check_for_key_exit
setkt:
mov cs:keys[kT	       ], 0
mov al, 'T'
jmp check_for_key_exit
setku:
mov cs:keys[kU	       ], 0
mov al, 'U'
jmp check_for_key_exit
setkv:
mov cs:keys[kV	       ], 0
mov al, 'V'
jmp check_for_key_exit
setkw:
mov cs:keys[kW	       ], 0
mov al, 'W'
jmp check_for_key_exit
setkx:
mov cs:keys[kX	       ], 0
mov al, 'X'
jmp check_for_key_exit
setky:
mov cs:keys[kY	       ], 0
mov al, 'Y'
jmp check_for_key_exit
setkz:
mov cs:keys[kZ	       ], 0
mov al, 'Z'
jmp check_for_key_exit
setk1:
mov cs:keys[k1	       ], 0
mov al, '1'
jmp check_for_key_exit
setk2:
mov cs:keys[k2	       ], 0
mov al, '2'
jmp check_for_key_exit
setk3:
mov cs:keys[k3	       ], 0
mov al, '3'
jmp check_for_key_exit
setk4:
mov cs:keys[k4	       ], 0
mov al, '4'
jmp check_for_key_exit
setk5:
mov cs:keys[k5	       ], 0
mov al, '5'
jmp check_for_key_exit
setk6:
mov cs:keys[k6	       ], 0
mov al, '6'
jmp check_for_key_exit
setk7:
mov cs:keys[k7	       ], 0
mov al, '7'
jmp check_for_key_exit
setk8:
mov cs:keys[k8	       ], 0
mov al, '8'
jmp check_for_key_exit
setk9:
mov cs:keys[k9	       ], 0
mov al, '9'
jmp check_for_key_exit
setk0:
mov cs:keys[k0	       ], 0
mov al, '0'
jmp check_for_key_exit

check_for_key_exit:
	ret
check_for_key endp