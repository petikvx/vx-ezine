;
; 浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様�
; � This file is generated by Interactive Disassembler (IDA)        �
; � Copyright (c) 1997 by DataRescue sprl, <ida@datarescue.com>     �
; 藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様�
;
;
 
		.Model Large,C
		.Code 
		Public	OptLink_UnPack

; 栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩�

OptLink_UnPack	Proc	Far
		Arg	Inp:DWord,Outp:DWord,W3:DWord
		Uses	Ds,Es,Si,Di,Cx
		Cld
		Lds	Si,Inp
		LodsW
		Les	Di,Outp
		Push	Si
		Push	Di
		Push	Ax
		Push	Bp
		Call	UnPack_Page
		Pop	Bp
		Pop	Ax
		Mov	Ax,Di
		Pop	Bx
		Sub	Ax,Bx
		Pop	Di
		Sub	Si,Di
		Les	Bx,W3
		Mov	Es:[Bx],Si
		Ret
OptLink_UnPack	EndP


; 栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩�

;		S u b r	o u t i	n e

UnPack_Page	proc near		; CODE XREF: BootApp+78p sub_0_752+Bp
		lodsw
; from [si++] to [di++]
		xor	cx, cx
		xchg	ax, bp
		mov	dx, 10h
		jmp	short loc_0_62
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�

loc_0_3A:				; CODE XREF: UnPack_Page+3Bj
		mov	bp, [si]
		mov	dl, 10h
		lea	si, [si+2]
		jmp	short loc_0_6E
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�

loc_0_43:				; CODE XREF: UnPack_Page+45j
		mov	bp, [si]
		mov	dl, 10h
		lea	si, [si+2]
		jmp	short loc_0_78
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�

loc_0_4C:				; CODE XREF: UnPack_Page+54j
		lodsw
		xchg	ax, bp
		mov	dl, 10h
		jmp	short loc_0_87
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�

loc_0_52:				; CODE XREF: UnPack_Page+5Bj
		lodsw
		xchg	ax, bp
		mov	dl, 10h
		jmp	short loc_0_8E
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�

loc_0_58:				; CODE XREF: UnPack_Page+34j
		mov	bp, [si]
		mov	dl, 10h
		lea	si, [si+2]
		jnb	loc_0_69

loc_0_61:				; CODE XREF: UnPack_Page+36j
		movsb

loc_0_62:				; CODE XREF: UnPack_Page+7j
					; UnPack_Page+6Ej ...
		add	bp, bp
		dec	dx
		jz	loc_0_58
		jb	loc_0_61

loc_0_69:				; CODE XREF: UnPack_Page+2Ej
		add	bp, bp
		dec	dx
		jz	loc_0_3A

loc_0_6E:				; CODE XREF: UnPack_Page+10j
		jb	loc_0_CB
		xor	bh, bh

loc_0_72:				; CODE XREF: UnPack_Page+A0j
					; UnPack_Page+A8j
		inc	cx
		add	bp, bp
		dec	dx
		jz	loc_0_43

loc_0_78:				; CODE XREF: UnPack_Page+19j
		adc	cx, cx
		cmp	cx, 2
		jz	loc_0_91

loc_0_7F:				; CODE XREF: UnPack_Page+C2j
					; UnPack_Page+116j
		xor	bh, bh
		push	cx
		add	bp, bp
		dec	dx
		jz	loc_0_4C

loc_0_87:				; CODE XREF: UnPack_Page+1Fj
		jb	loc_0_FD
		add	bp, bp
		dec	dx
		jz	loc_0_52

loc_0_8E:				; CODE XREF: UnPack_Page+25j
		jb	loc_0_AE

loc_0_90:				; CODE XREF: UnPack_Page+84j
					; UnPack_Page+98j
		pop	cx

loc_0_91:				; CODE XREF: UnPack_Page+4Cj
		mov	bl, [si]
		inc	si
		not	bx
		mov	ax, si
		lea	si, [bx+di]
		rep movs    byte ptr es:[di], byte ptr es:[si]
		mov	si, ax
		jmp	short loc_0_62
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�

loc_0_A1:				; CODE XREF: UnPack_Page+82j
		lodsw
		xchg	ax, bp
		mov	dl, 10h
		jmp	short loc_0_B5
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�

loc_0_A7:				; CODE XREF: UnPack_Page+8Ej
		lodsw
		xchg	ax, bp
		mov	dl, 10h
		jmp	short loc_0_C1
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
		nop	

loc_0_AE:				; CODE XREF: UnPack_Page+5Dj
		inc	bh
		add	bp, bp
		dec	dx
		jz	loc_0_A1

loc_0_B5:				; CODE XREF: UnPack_Page+74j
		jnb	loc_0_90
		mov	cx, 201h

loc_0_BA:				; CODE XREF: UnPack_Page+D7j
					; UnPack_Page+DCj ...
		xor	bh, bh

loc_0_BC:				; CODE XREF: UnPack_Page+94j
		add	bp, bp
		dec	dx
		jz	loc_0_A7

loc_0_C1:				; CODE XREF: UnPack_Page+7Aj
		adc	bh, bh
		dec	cl
		jnz	loc_0_BC
		add	bh, ch
		jmp	short loc_0_90
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�

loc_0_CB:				; CODE XREF: UnPack_Page+3Dj
		inc	cx
		add	bp, bp
		dec	dx
		jz	loc_0_10F

loc_0_D1:				; CODE XREF: UnPack_Page+E2j
		jnb	loc_0_72
		inc	cx
		add	bp, bp
		dec	dx
		jz	loc_0_132

loc_0_D9:				; CODE XREF: UnPack_Page+105j
		jnb	loc_0_72
		call	GetStreamWord
		mov	bx, 802h
		jnb	loc_0_138
		call	GetStreamWord
		mov	bx, 0C03h
		jnb	loc_0_138
		mov	cl, [si]
		inc	si
		cmp	cl, 81h
		mov	ch, 0
		jb	loc_0_7F
		jnz	locret_0_FC
		mov	cl, ch
		jmp	loc_0_62
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�

locret_0_FC:				; CODE XREF: UnPack_Page+C4j
		retn	
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�

loc_0_FD:				; CODE XREF: UnPack_Page+56j
		call	GetStreamWord
		jb	loc_0_115
		call	GetStreamWord
		mov	cx, 402h
		jnb	loc_0_BA
		mov	cx, 803h
		jmp	short loc_0_BA
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�

loc_0_10F:				; CODE XREF: UnPack_Page+9Ej
		lodsw
		xchg	ax, bp
		mov	dl, 10h
		jmp	short loc_0_D1
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�

loc_0_115:				; CODE XREF: UnPack_Page+CFj
		call	GetStreamWord
		mov	cx, 1004h
		jnb	loc_0_BA
		call	GetStreamWord
		mov	cx, 2004h
		jnb	loc_0_BA
		call	GetStreamWord
		mov	cx, 3004h
		jnb	loc_0_BA
		mov	cx, 4006h
		jmp	short loc_0_BA
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�

loc_0_132:				; CODE XREF: UnPack_Page+A6j
		lodsw
		xchg	ax, bp
		mov	dl, 10h
		jmp	short loc_0_D9
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�

loc_0_138:				; CODE XREF: UnPack_Page+B0j
					; UnPack_Page+B8j
		xor	cx, cx

loc_0_13A:				; CODE XREF: UnPack_Page+112j
		add	bp, bp
		dec	dx
		jz	loc_0_14A

loc_0_13F:				; CODE XREF: UnPack_Page+120j
		adc	cx, cx
		dec	bl
		jnz	loc_0_13A
		add	cl, bh
		jmp	loc_0_7F
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�

loc_0_14A:				; CODE XREF: UnPack_Page+10Cj
		mov	bp, [si]
		mov	dl, 10h
		lea	si, [si+2]
		jmp	short loc_0_13F
UnPack_Page	endp

; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
		align 2

; 栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩栩�

;		S u b r	o u t i	n e

GetStreamWord	proc near		; CODE XREF: UnPack_Page+AAp
					; UnPack_Page+B2p ...
		add	bp, bp
		dec	dx
		jz	loc_0_15A
		retn	
; 陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�

loc_0_15A:				; CODE XREF: GetStreamWord+3j
		mov	bp, [si]
		mov	dl, 10h
		lea	si, [si+2]
		retn	
GetStreamWord	endp

		End
