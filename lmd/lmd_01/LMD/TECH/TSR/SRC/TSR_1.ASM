; TSR_1 Example //Scout

Buffer_Size     EQU     0

jmp_FAR 	MACRO	Address
		db	0EAh
Address 	dd	?
		ENDM

Set_Vector	MACRO	Interrupt
		mov	di, OFFSET Old_Int_&Interrupt
		mov	dx, OFFSET Int_&Interrupt&_Handler
		mov	al, &Interrupt
		call	Set_Vect
		ENDM

Restore_Vector	MACRO	Interrupt
		mov	si, OFFSET Old_Int_&Interrupt
		mov	al, &Interrupt
		call	Restore_Vect
		ENDM

Chk_Vector      MACRO   Interrupt
		mov	al, Interrupt
		mov	si, OFFSET Int_&Interrupt&_Handler
                call    Chk_Vect
		ENDM

_CODE		SEGMENT PARA	PUBLIC	'Code'
		ASSUME	cs:_CODE, ds:_CODE, es:_CODE
		JUMPS

		ORG	100h

Start:
		jmp	Initialize

DOS_Flag_Addr   LABEL   DWORD
Offs		dw	?
Segm		dw	?

Flags		db	0

Int_09h_Handler PROC    FAR
                push    ax ds

		xor	ax, ax
		mov	ds, ax
		test	BYTE PTR ds:[0417h], 00001000b
		jz	Pass_09h

		in	al, 60h
		cmp	al, 39h
                jne     Pass_09h

		and	BYTE PTR ds:[0417h], 11110111b

		in	al, 61h
		or	al, 10000000b
		out	61h, al
		and	al, 01111111b
		out	61h, al

		mov	al, 20h
		out	20h, al

                or      cs:Flags, 00000001b

                pop     ds ax
		iret
Pass_09h:
                pop     ds ax
		jmp_FAR Old_Int_09h
Int_09h_Handler ENDP

Int_08h_Handler PROC    FAR
		test	cs:Flags, 00000010b
		jnz	Pass_08h
		test	cs:Flags, 00000001b
		jz	Pass_08h
		push	bx es
		les	bx, cs:DOS_Flag_Addr
		cmp	BYTE PTR es:[bx], 0
		jne	Exit_08h
		push	ax
		mov	al, 20h
		out	20h, al
		pop	ax
		call	Main
Exit_08h:
		pop	es bx
Pass_08h:
		jmp_FAR Old_Int_08h
Int_08h_Handler ENDP

Int_28h_Handler PROC	FAR
		test	cs:Flags, 00000010b
		jnz	Pass_28h
		test	cs:Flags, 00000001b
		jz	Pass_28h
		call	Main
Pass_28h:
		jmp_FAR Old_Int_28h
Int_28h_Handler ENDP

Main		PROC	NEAR
		or	cs:Flags, 00000010b

                sti

;               [ Куча всего ]
;               Например:

                push    ax
                mov     ax, 0E07h
                int     10h
                pop     ax
;

                and     cs:Flags, 11111100b
                retn
Main            ENDP

Int_2Fh_Handler PROC	FAR
		cmp	ax, 0FF00h
		jne	Pass_2Fh
		mov	al, 0FFh
		push	cs
		pop	es
		iret
Pass_2Fh:
		jmp_FAR Old_Int_2Fh
Int_2Fh_Handler ENDP

Initialize:
		mov	ax, 0FF00h
		int	2Fh
		or	al, al
		je	Install
Rest_V_?:
		mov	dx, es
                Chk_Vector      08h
                jc      Finish
                Chk_Vector      09h
                jc      Finish
                Chk_Vector      28h
                jc      Finish
                Chk_Vector      2Fh
                jc      Finish
Un_Install:
		Restore_Vector	08h
		Restore_Vector	09h
		Restore_Vector	28h
		Restore_Vector	2Fh
		mov	ah, 49h
		int	21h
                jmp     Finish

Install:
                mov     ah, 34h
		int	21h
                mov     Segm, es
		mov	Offs, bx

		mov	es, WORD PTR ds:[2Ch]
		mov	ah, 49h
		int	21h

		Set_Vector	08h
		Set_Vector	09h
		Set_Vector	28h
		Set_Vector	2Fh

                mov     dx, OFFSET Initialize + Buffer_Size
		int	27h
Finish:
		mov	ax, 4C00h
		int	21h

Chk_Vect        PROC    NEAR
		mov	ah, 35h
		int	21h
		mov	ax, es
		sub	ax, dx
		sub	bx, si
		or	ax, bx
		jnz	Un_Inst_Error
		clc
		ret
Un_Inst_Error:
		stc
		ret
Chk_Vect        ENDP

Restore_Vect    PROC    NEAR
		push	ds
		lds	dx, DWORD PTR es:[si]
		mov	ah, 25h
		int	21h
		pop	ds
		retn
Restore_Vect	ENDP

Set_Vect        PROC    NEAR
		mov	ah, 35h
		int	21h
		mov	WORD PTR [di], bx
		mov	WORD PTR [di+2], es
		mov	ah, 25h
		int	21h
		retn
Set_Vect	ENDP

_CODE		ENDS

		END	Start
        
