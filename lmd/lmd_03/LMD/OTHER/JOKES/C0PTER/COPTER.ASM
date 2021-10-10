; þ C0PtER v0.1

		model	tiny
		.code
		.286
		jumps
		org	100h
start:
		mov	ah,9
		mov	dx,offset copyright_msg
		int	21h
		mov	es,word ptr ds:[2ch]
		mov	ah,49h
		int	21h
		mov	ax,3508h
		int	21h
		mov	word ptr old_int_08h,bx
		mov	word ptr old_int_08h+2,es
		mov	dx,cs
		add	dx,(end_ptr+15) shr 4
		push	dx
		xor	si,si
		mov	ah,55h
		int	21h
		mov	es,dx
		mov	si,16h
		mov	di,si
		movsw
		push	cs
		pop	es
		mov	ah,49h
		int	21h
		mov	ax,5800h
		int	21h
		push	ax
		and	al,0fdh
		or	al,01h
		xchg	bx,ax
		mov	ax,5801h
		push	ax
		int	21h
		mov	bx,(tsr_size+15) shr 4
		mov	ah,48h
		int	21h
		mov	ds,ax
		dec	ax
		mov	es,ax
		inc	ax
		mov	word ptr es:[01h],ax
		mov	dx,int_08h-tsr_part
		mov	ax,2508h
		int	21h
		push	cs
		pop	ds
		mov	di,08h
		mov	si,offset mcb_part
		mov	cx,tsr_size+mcb_size
		rep	movsb
		pop	ax bx
		int	21h
		pop	bx
		mov	ah,50h
		int	21h
		retn

copyright_msg	db	'C0PtER v0.1 Copyright (C) '
		db	'1998 by Scout [SPS].',0dh,0ah,'$'

mcb_part:	db	'C0PtER !'
mcb_size	=	$-mcb_part

tsr_part:	db	'-/|\-'
int_08h:	pusha
		push	ds es cs 0b800h 0
		pop	ds
		mov	si,044ch
		lodsw
		xchg	ax,cx
		lodsw
		xchg	si,ax
		pop	ds es
next_char:	lodsw
		push	cx
		mov	cx,4
		xor	di,di
		repne	scasb
		jne	next
		mov	al,es:[di]
		mov	byte ptr ds:[si-2],al
next:		pop	cx
		loop	next_char
		pop	es ds
		popa
		db	0eah
old_int_08h	dd	?
tsr_size	=	$-tsr_part

end_ptr 	=	$-start+100h

		end	start
