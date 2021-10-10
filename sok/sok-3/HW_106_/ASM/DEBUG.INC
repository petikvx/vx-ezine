;
;	Модуль для отладки. Очень удобно распечатывать на экране
;	значения регитров. Содержит процедуры, поэтому вставлять
;	надо внутрь впрограммы, но желательно в самом начале.
;	В релиз его, естественно, вставлять не надо :)
;	
;	copyright by Ak Kort [SOS group]
;
;
$ShowEAX:
	push eax
	shr eax,16
	call $ShowAX
	pop eax
$ShowAX:				;Печать AX в HEX формате
	push ax
	shr ax,8
	call $ShowAL
	pop ax
$ShowAL:
	pusha
	push ax
	shr al,4
	call $ShowHex
	pop ax
	call $ShowHex
	popa
	retn
$ShowHex:			;печать одной HEX-цифры из AL
	and al,15
	add al,48
	cmp al,58
	jc $1
	add al,7
$1:
	push dx
	mov dl,al
	mov ah,2
	int 21h
	;mov ah,14
	;int 10h
	pop dx
	retn

$ShowLong:
	pushad
	mov cx,10
	mov di,offset $numlong
$2:	
	cmp eax,cs:[di]
	jnc $5
	add di,4
	loop $2
	mov ax,0E30h
	int 10h
	jmp short $3
$5:
	mov ebx,cs:[di]
	call $4
	add di,4
	loop $5
$3:	popad
	retn
	
$4:
	xor edx,edx
	div ebx
	add ax,14*256+48
	int 10h
	mov eax,edx
	retn

$ShowDec:				;печать AX в DEC формате
	pusha
	mov cx,5
	mov di,offset $numbers
$7:	
	cmp ax,cs:[di]
	jnc $6
	inc di
	inc di
	loop $7
	mov ax,0E30h
	int 10h
	jmp short $8
$6:
	xor dx,dx
$10:
	mov bx,cs:[di]
	call $9
	inc di
	inc di
	loop $10
$8:	
	popa
	retn
$9:
	xor dx,dx
	div bx
	add ax,14*256+48
	int 10h
	mov ax,dx
	retn

$numlong	dword 1000000000,100000000,10000000,1000000,100000
		dword 10000,1000,100,10,1
	
$numbers	word 10000,1000,100,10,1

$Next_Line:
	pusha
	mov ah,2
	mov dl,13
	int 33
	mov ah,2
	mov dl,10
	int 33
	popa
	retn

