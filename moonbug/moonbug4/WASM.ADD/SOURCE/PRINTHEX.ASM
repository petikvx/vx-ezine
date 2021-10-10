;Print numbers in hexadecimal format subroutines.	(C) 1996 J/SOFT.


printbhex				;print byte in hex (2 digits)
		mov ah,al		;in: AL=byte
		shr al			; destroys: AX.
		shr al
		shr al
		shr al
		call prtbh_half
		mov al,ah
		and al,15

prtbh_half	cmp al,10
		jnc prtbh1
		add al,'0'
		jmps prtbh2
prtbh1		sub al,10
		add al,'A'
prtbh2		int 29h
		retn

printwhex				;print word in hex (4 digits)
		push ax			;in: AX=word
		mov al,ah
		call printbhex		; destroys: AX.
		pop ax
		jmps printbhex
