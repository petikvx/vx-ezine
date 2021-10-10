; VirusHalt v1.2 (c) by Andrew V. Basharimoff
; 2:454/2.175@fidonet

offs	=	26ch

model tiny
codeseg
startupcode

		lea	dx,file
		mov	ax,3d02h
		int	21h
		jc	exit
		xchg	ax,bx
		xor	cx,cx
		mov	dx,offs
		mov	ax,4200h
		int	21h
		lea	dx,file
		mov	cx,3ech-offs
		mov	ah,3fh
		int	21h
		push	cx
		mov	si,dx
next:		neg	byte ptr [si]
		inc	si
		loop	next
		push	dx
		mov	dx,offs
		mov	ax,4200h
		int	21h
		pop	dx cx
		mov	ah,40h
		int	21h
		mov	ah,3eh
		int	21h
exit:		retn
file		db	'halt_mbr.bin',0
		end

