;Resident error interrupt handler.		(C) 1996 J/SOFT
;This program extends interrupt 0 (division by zero)
;and interrupt 4 (overflow)
	jmp intinit

i0	push cs
	pop ds
	call rte
	mov dx,offset d_ofl
	mov ah,9
	int 21h
	pop cx
	pop ax
	push cx

	call printwhex
	mov al,':'
	int 29h
	pop ax
	dec ax
	dec ax
	call printwhex
	mov dx,offset endln
	mov ah,9
	int 21h

	mov ax,4c00h
	int 21h
d_ofl	db 13,10,'Division by zero at PC=$'
	include 'printhex'

i4	push cs
	pop ds
	call rte
	mov dx,offset ofl
	mov ah,9
	int 21h
	pop cx
	pop ax
	push cx
	call printwhex
	mov al,':'
	int 29h
	pop ax
	dec ax
	dec ax
	call printwhex
	mov dx,offset endln
	mov ah,9
	int 21h
	mov ax,4c00h
	int 21h
ofl	db 13,10,'Overflow at PC=$'
endln	db 13,10,7,'$'
rte	mov dx,offset rter
	mov ah,9
	int 21h
	retn
rter	db 13,10,'Run-Time error:$'

intinit mov ax,2500h
	mov dx,offset i0
	int 21h
	mov ax,2504h
	mov dx,offset i4
	int 21h
	mov dx,offset intinit
	int 27h
