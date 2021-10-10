;Print numbers in decimal format subroutines.  Converted from TASM by J/SOFT.

textnum 	db '00000'
textnumend	db 0,'$'

bintoascii
		mov bx,10
		mov si,cs
		mov es,si
		mov si,offset textnumend-1
		mov cx,5

divloop 	sub dx,dx
		div bx
		add dl,'0'
		es:
		mov [si],dl
		dec si
		loop divloop
		retn

printbyte	push ax 	;decodes a byte (in AL) and displays it as 3
		push cx 	;digits plus an optional sign. If the carry is
		push dx 	;clear, it prints it as an unsigned integer.
		push bx 	;If the carry is set, it prints it signed.
		jnc skipsignb	;EX.:	mov al,-50
		xor ah,ah	;	stc		(signed)
		test al,10000000b;	call printbyte
		jz skipsignb
		neg al
		push ax
		mov ah,2
		mov dl,'-'
		int 21h
		pop ax
		jmp skipb
skipsignb	xor ah,ah
		push ax
		mov ah,2
		mov dl,' '
		int 21h
		pop ax
skipb		call bintoascii
		mov ax,cs
		mov ds,ax
		mov dx,offset textnum+2
		mov ah,9
		int 21h

		pop bx
		pop dx
		pop cx
		pop ax
		retn

printword	push ax 	;decodes and prints a WORD (in AX) in 5 digits.
		push cx 	;EX.:	mov ax,50000
		push dx 	;	call printword
		push bx
		jnc skipsignw
		test ah,10000000b
		jz skipsignw
		neg ax
		push ax
		mov ah,2
		mov dl,'-'
		int 21h
		pop ax
		jmp skipw
skipsignw	push ax
		mov ah,2
		mov dl,' '
		int 21h
		pop ax
skipw		call bintoascii
		mov ax,cs
		mov ds,ax
		mov dx,offset textnum
		mov ah,9
		int 21h

		pop bx
		pop dx
		pop cx
		pop ax
		retn
