; Набольшая патчилка для DrWeb'a. Тестировалась на DrWeb v.4.11

Pos	=	0D0h-3Dh-SigLen
Posl	=	40h

.model tiny
.386
.code
	org 100h
Main:	mov si,offset Sig		; Сигнатура
	xor bp,bp
	mov ax,3D02h
	mov dx,offset drweb
	int 21h
	xchg	ax,bx
	jnc	Okay
	ret
Okay:	mov	ax,4200h
	xor	cx,cx
	mov	dx,0F467h
	int	21h
Find:	mov ah,3Fh
	mov dx,offset Free		; Читаем байт
	mov cx,1
	int 21h
	or  ax,ax
	jz	Err
	mov di,dx
	inc	bp
	cmpsb
	jz 	Same
	mov	si,offset Sig
	xor	bp,bp
	jmp	NSame
Same:	nop
NSame:	cmp	bp,SigLen
	jb	Find
	mov	ax,4201h
	xor	cx,cx
	cwd
	int	21h
	xchg	ax,dx
	xchg	ax,cx
	mov	ax,4200h
	add	dx,Pos
	adc	cx,0
	int	21h
	mov	P1,ax
	mov	P2,dx
	mov	ah,3fh
	mov	dx,offset Free
	mov	cx,Posl
	int	21h
	mov	ax,0FF03h
	cmp	2 ptr [Free][0],ax
	jnz	Err
	mov	al,0E9h
	cmp	1 ptr [Free][7],al
	jnz	Err
	mov	ax,2 ptr [Free][8]
	mov	OldP,ax				; Сохраним куда Jmp
	mov 	ax,099CDh
	mov	2 ptr [Free][0],ax		; int 99h
	mov	2 ptr [Free][7],ax		; int 99h
	mov	ax,4200h
	mov	cx,P2
	mov	dx,P1
	int	21h
	mov	ah,40h
	mov	dx,offset Free
	mov	cx,PosL
	int	21h
	mov	ah,3eh
	int	21h
	mov	ax,3D01h
	mov	dx,offset Logger
	int	21h
	xchg	ax,bx
	mov	ax,4202h
	xor	cx,cx
	cwd
	int	21h
	sub	ax,2
	sbb	dx,0
	xchg	ax,dx
	xchg	ax,cx
	mov	ax,4200h
	int	21h
	mov	ah,40h
	mov	dx,offset OldP
	mov	cx,2
	int	21h
	mov	ah,3eh
	int	21h
	mov	ah,9
	mov	dx,offset Patched
	int	21h
	ret
Err:	mov	ah,3eh
	int	21h
	mov	ah,9
	mov	dx,offset Error
	int	21h
	ret
Sig	db	26h,8Bh,07h,03Dh,0FFh,0FFh,074h,0A7h
SigLen	equ	$ - Sig
DrWeb	db	'drweb.exe',0
logger	db	'sniffer.com',0
Error	db	'Signature not found,DrWeb not patched !!!',13,10,'$'
Patched	db	'Signature found,patch successful',13,10,'$'
OldP	dw	?
P1	dw	?
P2	dw	?
Free:
End	main