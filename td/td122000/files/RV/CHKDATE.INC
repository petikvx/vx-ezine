		mov ah,2Ah
		call INT21

		sub cx,1980d
		shl cx,4
		or cl,dh
		shl cx,5

		mov ax,FileDate
		and al,0E0h
		xor cx,ax
		jnz ReadHeader
		jmp Close&Restore

ReadHeader: