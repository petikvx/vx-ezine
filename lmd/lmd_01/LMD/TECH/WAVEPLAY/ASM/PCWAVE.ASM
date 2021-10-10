title	pcwave.plm
subttl	PLM 1.5  Moscow, 8-Jul-92

 buffersize      	equ	 15000
	crlf   equ     0dh, 0ah

.model	tiny, pascal
LOCALS
.code
JUMPS
	org 100h
	.286
	locals _@
pcwave:
	ifnb <copyrightmsg>
	mov	dx,offset copyrightmsg
	endif
	mov	ah,09h
	int	21h
	xor	bx,bx
	mov	bl,ds:[80h]
	push	cx
	mov	byte ptr ds:[bx+81h],00h
	mov	byte ptr ds:[bx+82h],"$"
	pop	cx
	sub	bl,3
	jnc	@@l1
	mov	dx,offset clerrormsg
	jmp	finish
@@l1:
	ifnb <firstmsg>
	mov	dx,offset firstmsg
	endif
	mov	ah,09h
	int	21h
	ifnb <81h>
	mov	dx,offset 81h
	endif
	int	21h
	ifnb <crlfstr>
	mov	dx,offset crlfstr
	endif
	int	21h
	mov	ax,3d00h
	mov	dx,82h
	int	21h
	jnc	@@l2
	mov	dx,offset openerrormsg
	jmp	finish
@@l2:
	mov	handle,ax
	xchg	bx,ax
	mov	ah,3fh
	mov	cx,44
	mov	dx,offset buffer
	int	21h
	jnc	@@l3
	mov	ah,3eh
	mov	bx,handle
	int	21h
	mov	dx,offset readerrormsg
	jmp	finish
@@l3:
	cmp	word ptr [buffer+22],01h
	je	@@l4
	mov	ah,3eh
	mov	bx,handle
	int	21h
	mov	dx,offset monoerrormsg
	jmp	finish
@@l4:
	cli
	mov	ax,3508h
	int	21h
	mov	word ptr (old_int_08h+2),es
	mov	word ptr old_int_08h,bx
	mov	dx,offset int_08h
	mov	ax,2508h
	int	21h
	mov	al,36h
	out	43h,al
	mov	ax,word ptr [buffer+24]
	xor	dx,dx
	mov	cx,19
	div	cx
	mov	freq,ax
	xor	dx,dx
	xor	cx,cx
	mov	ax,1234h
	mov	cl,[buffer+25]
	div	cx
	dec	al
	dec	al
	out	40h,al
	xchg	al,ah
	out	40h,al
	sti
	mov	al,0b0h
	out	43h,al
	mov	al,01h
	out	42h,al
	xor	al,al
	out	42h,al
	in	al,61h
	or	al,03h
	out	61h,al
	mov	al,90h
	out	43h,al
	jmp	readfirstpart
nexttest:
	mov	ah,01h
	int	16h
	jne	@@l5
	test	flags,00000010b
	je	@@l6
	cmp	buff2size,00h
	jne	@@l7
	mov	bx,handle
	mov	ah,3fh
	mov	cx,buffersize
	mov	dx,offset buffer2
	int	21h
	jc	filereaderror
	mov	buff2size,ax
@@l7:
	cmp	buff1size,00h
	jne	@@l8
readfirstpart:
	mov	bx,handle
	mov	ah,3fh
	mov	cx,buffersize
	mov	dx,offset buffer1
	int	21h
	jnc	@@l9
filereaderror:
	call	deinitialize
	mov	dx,offset readerrormsg
	jmp	finish
@@l9:
	mov	buff1size,ax
	and	flags,11111110b
@@l8:
	or	ax,ax
	jne	@@l10
	and	flags,11111101b
@@l10	equ	@@l11
	jmp	@@l11
@@l6:
	cmp	buff2size,00h
	jne	@@l12
	cmp	buff1size,00h
	je	deinit
@@l12:
@@l11	equ	@@l13
	jmp	@@l13
@@l5:
	xor	ax,ax
	int	16h
	jmp	deinit
@@l13:
	jmp	nexttest
deinit:
	call	deinitialize
	mov	dx,offset okmsg
finish:
	ifnb <>
	mov	dx,offset
	endif
	mov	ah,09h
	int	21h
	mov	ax,4c00h
	int	21h
	PUBLIC	deinitialize

deinitialize	PROC
	USES	
	mov	dx,word ptr old_int_08h
	mov	ds,word ptr (old_int_08h+2)
	mov	ax,2508h
	int	21h
	push	cs
	pop	ds
	mov	al,36h
	out	43h,al
	xor	al,al
	out	40h,al
	jmp	$+2
	jmp	$+2
	out	40h,al
	mov	ah,3eh
	mov	bx,handle
	int	21h
	ret
deinitialize	ENDP

	PUBLIC	int_08h

int_08h	PROC	 far
	USES	
	pusha
	push	ds
	push	cs
	pop	ds
	test	flags,00000001b
	jne	pass_08h
	cmp	buffflag,00h
	jne	@@l14
	cmp	buff2size,00h
	jne	@@l15
	cmp	buff1size,00h
	je	@@l16
	mov	buffflag,0ffh
	mov	buffoffs,offset buffer1
	jmp	playbuff1
@@l16:
	jmp	pass_08h
@@l17	equ	@@l18
@@l15:
playbuff2:
	dec	buff2size
	mov	bx,buffoffs
	inc	buffoffs
@@l18	equ	@@l19
	jmp	@@l19
@@l14:
	cmp	buff1size,00h
	jne	@@l20
	cmp	buff2size,00h
	je	@@l21
	mov	buffflag,00h
	jmp	playbuff2
@@l21:
	jmp	pass_08h
@@l22	equ	@@l23
@@l20:
playbuff1:
	dec	buff1size
	mov	bx,buffoffs
	inc	buffoffs
@@l23	equ	@@l19
@@l19:
	mov	al,byte ptr [bx]
	mov	bx,offset pctable
	xlat
	out	42h,al
pass_08h:
	inc	counter
	mov	ax,counter
	cmp	ax,freq
	ja	go_int_08h
	mov	al,20h
	out	20h,al
	pop	ds
	popa
	iret
go_int_08h:
	mov	counter,00h
	pop	ds
	popa
	db	0eah
old_int_08h	db	4 dup(?)
int_08h	ENDP

copyrightmsg	db	crlf,"WAVEPlayer Version 1.0 Copyright (C) 1997 by Scout, SPS.",crlf,"$"
clerrormsg	db	crlf,"Usage: pcwave.com FileName",crlf,"$"
monoerrormsg	db	crlf,"This WAVE file is not 8-bit mono.",crlf,"$"
firstmsg	db	crlf,"Playing File:$"
readerrormsg	db	crlf,"File Read Error.",crlf,"$"
openerrormsg	db	crlf,"File Open Error.",crlf,"$"
crlfstr	db	crlf,"$"
okmsg	db	crlf,"OK/OB!!",crlf,"$"
flags	db	00000011b
counter	dw	0
buff1size	dw	0
buff2size	dw	0
buffflag	db	0
pctable	db	1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
	db	2,2,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4
	db	4,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5
	db	5,5,5,6,6,6,6,6,6,6,6,6,6,6,6,6,7
	db	7,7,7,7,7,7,7,7,7,7,8,8,8,8,8,8,8
	db	8,8,8,8,8,8,9,9,9,9,9,9,9,10,10,10,10
	db	11,11,12,12,13,14,14,15,16,17,17,18,19,20,21,22,23
	db	24,26,27,28,29,30,31,33,34,35,36,38,39,40,41,43,44
	db	45,46,48,49,50,51,52,53,54,55,57,58,58,59,60,61,62
	db	63,64,64,65,66,66,67,67,67,67,67,67,68,68,68,68,68
	db	68,68,68,68,68,68,68,68,69,69,69,69,69,69,69,69,69
	db	69,69,70,70,70,70,70,70,70,70,70,70,70,70,70,71,71
	db	71,71,71,71,71,71,71,71,71,72,72,72,72,72,72,72,72
	db	72,72,72,72,72,73,73,73,73,73,73,73,73,73,73,73,74
	db	74,74,74,74,74,74,74,74,74,74,74,74,75,75,75,75,75,75
buffoffs	dw	?
freq	dw	?
handle	dw	?
buffer	label	byte
buffer1	db	buffersize dup(?)
buffer2	db	buffersize dup(?)
end	pcwave