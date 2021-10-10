__MASK_MOV		equ		88h
__MASK_XCHG		equ		86h
__MASK_MOV_IM		equ		0B0h
__MASK_ADD		equ		00h
__MASK_POP		equ		58h
__MASK_PUSH		equ		50h
__MASK_LEA		equ		__CMD_LEA
__MASK_IMUL		equ		__CMD_IMUL
__MASK_IMUL2		equ		6Bh

__MASK_INC40		equ		40h
__MASK_DEC48		equ		48h


__MASK_80		equ		80h		; SUB = 101b
							; ADD = 000b

__MASK_F6		equ		0F6h		; NEG = 011b
							; NOT = 010b

__MASK_FE		equ		0FEh		; INC = 000b
							; DEC = 001b

__MASK_C0		equ		0C0h            ; SHL=100b


;__MASK_SHL		equ		0C0h            ; r/o=100b


__CMD_LEA		equ		8Dh
__CMD_IMUL		equ		69h
__CMD_NOP		equ		90h
