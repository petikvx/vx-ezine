.model  tiny
.code
.286
		org 100h

start:          mov     ah, 9
		mov	dx, offset cpemessage
		int	21h
		call	initseeds
		mov	cx, 32h
fixnextfilename:push    cx
		cmp	byte ptr genfile+7, 39h
		jz	fixit
		inc	byte ptr genfile+7
		jmp short createfile
fixit:          mov     byte ptr genfile+7, 30h
		inc	byte ptr genfile+6
createfile:     mov     ah, 3Ch
		xor	cx, cx
		mov	dx, offset genfile
		int	21h
		jnb	filecreated
		jmp short exitgenfiles
filecreated:    push    ax
		mov	ah, 9
		mov	dx, offset genfilemessage
		int	21h
		mov	si, offset dummystart
                mov     cx, dummyend-dummystart
		mov	ax, 200h
		mov	bx, 100h
		mov	bp, 100h
		mov	di, offset end_cpe
		call	cpe
		mov	ah, 40h
		pop	bx
		int	21h
		mov	ah, 3Eh
		int	21h
		pop	cx
		loop	fixnextfilename
exitgenfiles:   int     20h
dummystart:     nop 
		nop	
		nop	
		mov	ah, 9
		call	dummy_getip
dummy_getip:    pop     dx
		add	dx, 7
		int	21h
                db      0cdh
db ' This file was created by CPE 0.11b (Compact Polymorphic Engine),',0Ah,0Dh
db ' CPE was coded in 1994 by Peter Demenuk.',0Ah,0Dh,'$'
dummyend:
genfilemessage  db 0Dh,'CPE generate file: '
genfile         db '000000/9.COM',0
                db '$'
cpemessage      db '  CPE version 0.11 Beta.',0Ah,0Dh
                db '  Copyright (c) 1994 by Peter Demenuk ',0Ah,0Dh,'$'

                include cpe.asm

		end start

