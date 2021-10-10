title	waveplay.plm
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
wavplayer:
	ifnb <copyrightmsg>
	mov	dx,offset copyrightmsg
	endif
	mov	ah,09h
	int	21h
	mov	bx,0200h
	mov	cx,10
@@l1:
	push	cx
	mov	dx,bx
	add	dx,06h
	mov	al,1
	out	dx,al
	in	al,dx
	in	al,dx
	in	al,dx
	in	al,dx
	xor	al,al
	out	dx,al
	mov	dx,bx
	add	dx,0ah
	mov	cx,100
@@l3:
	in	al,dx
	cmp	al,0aah
	loopne	@@l3
@@l4:
	pop	cx
	je	sbfound
	add	bx,10h
	loop	@@l1
@@l2:
sbnotfound:
	mov	dx,offset sberrormsg
	jmp	finish
sbfound:
	mov	sbport,bx
	xor	bx,bx
	mov	bl,ds:[80h]
	push	cx
	mov	byte ptr ds:[bx+81h],00h
	mov	byte ptr ds:[bx+82h],"$"
	pop	cx
	sub	bl,3
	jnc	@@l5
	mov	dx,offset clerrormsg
	jmp	finish
@@l5:
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
	jnc	@@l6
	mov	dx,offset openerrormsg
	jmp	finish
@@l6:
	mov	handle,ax
	xchg	bx,ax
	mov	ah,3fh
	mov	cx,44
	mov	dx,offset buffer
	int	21h
	jnc	@@l7
	mov	ah,3eh
	mov	bx,handle
	int	21h
	mov	dx,offset readerrormsg
	jmp	finish
@@l7:
	cmp	word ptr [buffer+22],01h
	je	@@l8
	mov	ah,3eh
	mov	bx,handle
	int	21h
	mov	dx,offset monoerrormsg
	jmp	finish
@@l8:
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
	mov	al,0d1h
	call	write2dac
	jmp	readfirstpart
nexttest:
	mov	ah,01h
	int	16h
	jne	@@l9
	test	flags,00000010b
	je	@@l10
	cmp	buff2size,00h
	jne	@@l11
	mov	bx,handle
	mov	ah,3fh
	mov	cx,buffersize
	mov	dx,offset buffer2
	int	21h
	jc	filereaderror
	mov	buff2size,ax
@@l11:
	cmp	buff1size,00h
	jne	@@l12
readfirstpart:
	mov	bx,handle
	mov	ah,3fh
	mov	cx,buffersize
	mov	dx,offset buffer1
	int	21h
	jnc	@@l13
filereaderror:
	call	deinitialize
	mov	dx,offset readerrormsg
	jmp	finish
@@l13:
	mov	buff1size,ax
	and	flags,11111110b
@@l12:
	or	ax,ax
	jne	@@l14
	and	flags,11111101b
@@l14	equ	@@l15
	jmp	@@l15
@@l10:
	cmp	buff2size,00h
	jne	@@l16
	cmp	buff1size,00h
	je	deinit
@@l16:
@@l15	equ	@@l17
	jmp	@@l17
@@l9:
	xor	ax,ax
	int	16h
	jmp	deinit
@@l17:
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
	mov	al,0d3h
	call	write2dac
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
	jne	@@l18
	cmp	buff2size,00h
	jne	@@l19
	cmp	buff1size,00h
	je	@@l20
	mov	buffflag,0ffh
	mov	buffoffs,offset buffer1
	jmp	playbuff1
@@l20:
	jmp	pass_08h
@@l21	equ	@@l22
@@l19:
playbuff2:
	dec	buff2size
	mov	bx,buffoffs
	inc	buffoffs
@@l22	equ	@@l23
	jmp	@@l23
@@l18:
	cmp	buff1size,00h
	jne	@@l24
	cmp	buff2size,00h
	je	@@l25
	mov	buffflag,00h
	jmp	playbuff2
@@l25:
	jmp	pass_08h
@@l26	equ	@@l27
@@l24:
playbuff1:
	dec	buff1size
	mov	bx,buffoffs
	inc	buffoffs
@@l27	equ	@@l23
@@l23:
	mov	al,10h
	call	write2dac
	mov	al,byte ptr [bx]
	call	write2dac
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

	PUBLIC	write2dac

write2dac	PROC
	USES	
	mov	ah,al
next:
	mov	dx,sbport
	add	dx,0ch
	in	al,dx
	test	al,80h
	jne	next
	mov	al,ah
	out	dx,al
	ret
write2dac	ENDP

copyrightmsg	db	crlf,"WAVEPlayer Version 1.0 Copyright (C) 1996 by Scout, SPS.",crlf,"$"
clerrormsg	db	crlf,"Usage: waveplay.com FileName",crlf,"$"
sberrormsg	db	crlf,"Sound Blaster not found.",crlf,"$"
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
buffoffs	dw	?
freq	dw	?
sbport	dw	?
handle	dw	?
buffer	label	byte
buffer1	db	buffersize dup(?)
buffer2	db	buffersize dup(?)
end	wavplayer