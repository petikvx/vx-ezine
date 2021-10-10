;
;	отладочный модуль. Содержит макрос для распечатки значений
;	вставлять нужно в самом начале программы.
;	пример обращения: @Message 'Значение dx=',dx
;
;	copyright by Ak Kort [SOS group]
;
@Message MACRO @@s,@@r
	local @@l,@@m
	.386
	jmp short @@l
@@m	db @@s,"$"
@@l:	pusha
	push ds

	push cs
	pop ds
	lea dx,@@m
	mov ah,9
	int 21h
	pop ds
	popa
	push eax
	IF (TYPE(@@r) EQ 1)
	  mov al,@@r
	  call $ShowAL
	ELSEIF (TYPE(@@r) EQ 2)
	  mov ax,@@r
	  call $ShowAX
	ELSE
;	  mov eax,@@r
	  call $ShowEAX
	ENDIF
	call $Next_Line
	pop eax
;	.8086
ENDM

@Asciz MACRO s,r
	local @@l,@@m,@@n,@@o
	jmp short @@l
@@m	db s,"$"
@@l:	pusha
	push ds

	push cs
	pop ds
	lea dx,@@m
	mov ah,9
	int 21h
	pop ds
	popa
	pusha
	mov si,r
	cld
@@o:	lodsb
	or al,al
	jz @@n
	mov dl,al
	mov ah,2
	int 21h
	jmp @@o
@@n:
	call $Next_Line
	popa
ENDM
