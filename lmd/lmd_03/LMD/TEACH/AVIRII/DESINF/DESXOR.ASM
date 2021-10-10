COMMENT |

DESINFECTOR source for free spreading.

(c) 1993-96 by Andrew V. Basharimoff (2:454/2.175@fidonet)

|

DELTA		=	0dh		;<- stored from desinf.com !
DLENGTH 	=	45fbh		;change if it's needed !

model tiny
codeseg
startupcode

	lea	dx,file
	mov	ax,3d12h
	int	21h
	jb	error
	xchg	bx,ax
	mov	ah,3fh
	mov	dx,300h
	mov	cx,-1
	int	21h
	jb	close
	push	ax
	mov	si,300h+DELTA
	mov	cx,DLENGTH
xorit:	xor	1 ptr [si],23h
	inc	si
	loop	xorit
	mov	dx,cx
	mov	ax,4200h
	int	21h
	mov	ah,40h
	mov	dh,3
	pop	cx
	int	21h
close:	mov	ah,3eh
	int	21h
error:	retn

file	db	'desinf.com',0

	end
