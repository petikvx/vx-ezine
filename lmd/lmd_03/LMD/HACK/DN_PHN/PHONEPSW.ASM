.286
Code		segment
Assume		cs:Code,ds:Code,es:Code,ss:Code
		org	100h
Start:
		db	'[WRITTEN_BY_BEHEMOT]',13,10,'!'
		mov	ah,9
		mov	dx,offset Text_3
		int	21h
		mov	ax,3D00h
		mov	dx,offset File
		int	21h
		jc	Error
		xchg	ax,bx
		mov	cx,65535
		mov	ah,3Fh
		mov	dx,offset Buffer
		mov	si,dx
		mov	bp,dx
		int	21h
		jc	Exit
		add	bp,ax
		cld
Phone_000:
		cmp	si,bp
		je	Exit
		lodsb
		cmp	al,8Ah
		jne	Phone_000
		lodsb
		cmp	al,20h
		jne	Phone_000
	push	si
		mov	si,offset Text_1
		call	Pascal_Str_Write
		inc	byte ptr ds:[Text_1+1]
	pop	si
		call	Pascal_Str_Write
		call	Send_CRLF
		xor	ah,ah
		lodsb
		add	si,ax
		lodsb
		add	si,ax
		call	Decode
	push	si
		mov	si,offset Text_2
		call	Pascal_Str_Write
	pop	si
		call	Pascal_Str_Write
		call	Send_CRLF
		jmp	Phone_000
Exit:
		int	20h
Error:
		mov	ah,9
		mov	dx,offset Text_4
		int	21h
		int	20h

Send_CRLF	proc near
		mov	al,0Dh
		int	29h
		mov	al,10
		int	29h
		ret
Send_CRLF	endp

Pascal_Str_Write proc
		lodsb
		or	al,al
		je	Pascal_001
		xor	cx,cx
		mov	cl,al
Pascal_000:
		lodsb
		int	29h
		loop	Pascal_000
Pascal_001:
		ret
Pascal_Str_Write endp

Decode		proc
	push	si
		lodsb
		or	al,al
		je	Decode_001
		xor	cx,cx
		mov	cl,al
		mov	bx,offset Key
		mov	di,si
Decode_000:
		lodsb
		xor	al,[bx]
		inc	bx
		stosb
		loop	Decode_000
Decode_001:
	pop	si
		ret
Decode		endp
File		db 'dn.phn',0
Key		db 0CAh, 0FEh, 0C0h, 0E9h, 0CEh, 0F8h, 0C2h, 0F0h
		db 0EDh, 0C1h, 0F7h, 0CFh, 0E0h, 0C5h, 0F1h
Text_1		db 14,'1. Group    : '
Text_2		db 14,'   Password : '
Text_3		db 'DN Phone Book password cracker.',13,10
		db 'Written by BeHeMoT.',13,10,'$'
Text_4		db 'Check whether dn.phn is in current directory.',13,10,'$'
Buffer		equ $
Code		ends
end		Start
