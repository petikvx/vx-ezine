;-----------------------------------------------------
; RDCG v0.2
;-----------------------------------------------------
;- BzZ Random De- Cryptor Generator by B!Z0n //[BzZ] -
;-----------------------------------------------------
; Input  : DS:SI - End of Cryptor
;	 : ES:DI - Start of Decryptor
;	 : CX	 - Num of De- Crypt command length
; Output : ES:SI - Start of Cryptor
;	 : ES:DI - End of Decryptor
;	 : CX	 - Len of Decryptor (Encryptor) Bytes
;	 : AX, SI,DI - destroyed
;----------------------------------------------------
RDCG   proc	near
       mov	byte ptr [si], 0C3h
       push	si
@0:
       call	codegen
       loop	@0
       pop	cx
       sub	cx, si
       ret
BzZ_RDCG	db  0,'[BzZ RDCG]',0
;-------------------------------------
codegen:
       in	al, 40h
       shr	al, 3
       jne	@A
       call	incdec
       ret
@A:    shr	al, 3
       jne	@B
       call	rox
       ret
@B:    call	ArOp1
       ret
;-------------------------------------
INCDEC	proc	near
	sub	si, 02h
	in	ax, 40h
	and	ax, 0000110111111110b
	or	ax, 0000010111111110b
	stosw
	xor	ah, 11110111b
	not	ah
	xchg	si, di
	stosw
	xchg	si, di
	sub	si, 02h
	ret
INCDEC	endp
;-------------------------------------
ROX	proc	near
	sub	si, 03h
	in	ax, 40h
	and	ax, 0000110111000000b
	or	ax, 0000010111000000b
	stosw
	xor	ah, 11110111b
	not	ah
	xchg	si, di
	stosw
	xchg	si, di
	in	al, 40h
	stosb
	xchg	si, di
	stosb
	xchg	si, di
	sub	si, 03h
	ret
ROX	endp
;-------------------------------------
;-------------------------------------
;-------------------------------------
ArOp1	proc	near
	push	bx
	in	ax, 40h
;-----------------------
	test	al, 00000001b
	je	@3
	mov	bx, 0004h
	jmp	@4
@3:	mov	bx, 0003h
@4:	sub	si, bx
;-----------------------
	and	ax, 0010110110000001b
	or	ax, 0000010110000000b
	test	ah, 00001000b
	je	@1
	or	ah, 00101000b
	jmp	@2
@1:	and	ah, 11000111b
@2:	stosw
	xchg	si, di
	xor	ah, 11010111b
	not	ah
	stosw
	xchg	si, di
;-----------------------
	in	al, 40h
	call	@5
	xchg	si, di
	call	@5
	xchg	si, di
	sub	si, bx
	pop	bx
	ret
@5:	test	bl, 01b
	je	@6
	stosb
	jmp	@7
@6:	stosw
@7:	ret
ArOp1	endp
;------------------------------------
RDCG	endp
;------------------------------------------------------------------
