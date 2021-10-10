comment ■

Exe2Com.Asm, Exe2Com - Основной модуль.

//Scout [SPS] ■

l_len		=	128

		model	tiny
		.code
		org	0
begin:		org	81h
com_line:	org	100h
		jumps

start:		mov	dx,offset copyright
		mov	ah,09h
		int	21h
		mov	si,offset com_line
		mov	dx,offset help
next_blank:	lodsb
		cmp	al,' '
		je	next_blank
		cmp	al,0dh
		je	finish
make_name:	push	si ax
		mov	dx,offset file
		mov	ah,09h
		int	21h
		pop	ax
		mov	cx,80h-1
next_chr:	cmp	al,'a'
		jb	print_chr
		cmp	al,'z'
		ja	print_chr
		and	al,11011111b
print_chr:	int	29h
		lodsb
		cmp	al,' '
		je	end_of_name
		cmp	al,0dh
		loopne	next_chr
end_of_name:	mov	byte ptr [si-1],ch
		pop	dx
		dec	dx
		mov	ax,3d02h
		int	21h
		mov	dx,offset load
		jc	finish
		xchg	ax,bx
		mov	dx,offset buffer
		mov	ah,3fh
		mov	cx,0ffffh-(buffer-begin+100h)
		int	21h
		cmp	ax,cx
		mov	dx,offset long
		je	exit
		xchg	cx,ax
		mov	ax,word ptr [buffer]
		not	ax
		mul	ah
		sub	ax,72bah
		mov	dx,offset com
		jnz	exit
		push	cx
		mov	ah,42h
		cwd
		xor	cx,cx
		int	21h
		pop	cx
		mov	dx,offset loader
		add	cx,l_len
		mov	ah,40h
		int	21h
		mov	dx,offset save
		jc	exit
		mov	dx,offset tnx
exit:		push	dx
		mov	ah,3eh
		int	21h
		pop	dx
finish: 	mov	ah,09h
		int	21h
		retn

copyright	db	'Exe2Com v0.01 Copyright (C) 1998 by Scout [SPS].'
		db	0dh,0ah,'$'
help		db	'Usage: Exe2Com.Com FileName$'
file		db	'File: $'
ok		db	' - OK.$'
load		db	' - load error.',7,'$'
save		db	' - save error.',7,'$'
com		db	' - com-file.',7,'$'
long		db	' - file too long.',7,'$'
tnx		db	0dh,0ah,'Thanx 4 usage Exe2Com.$'

loader		db	l_len	dup	(?)
buffer: 	end	start

