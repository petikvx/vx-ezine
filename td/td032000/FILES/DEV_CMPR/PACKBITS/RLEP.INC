; Размер = 135 bytes
; Упаковка PackBits
; Ds:Si - Data to pack
; Es:Di - Where put packed data
; Cx    - Source data length

RLEP	proc
	push di cx
	add di,4
	mov NoMatched,si
	xor dx,dx
	xor bx,bx
RLEPack:
	lodsb				; Берем байт
	cmp al,dl			; Предидущий такой ?
	jne NotEqual			; Нет
	cmp bl,0			; Такой. Были непохожие символы
	jz IncEqual
	Call DropNotEqual		; Скидываем их
IncEqual:
	inc bh				; Увеличиваем кол-во совпавших
	cmp bh,126			; > 126 ?
	jb OkMatch			; Все нормально
	Call DropEqual			; Переполнение. Скидываем похожие
OkMatch:jmp RLEPLoop			; Cлед. байт
NotEqual:
	cmp bh,0			; Были повторяющиеся ?
	jz IncNotEqual
	Call DropEqual			; Да. Скидываем их
IncNotEqual:
	inc bl
	cmp bl,126
	jb OkNoMatch
	Call DropNotEqual		; Переполнение ?
OkNoMatch:
RLEPLoop:
	mov dl,al
	loop RLEPack			; Поехали

	cmp bl,0
	jz NoDrop1
	Call DropNotEqual		; Остались хвосты ?
NoDrop1:
	cmp bh,0
	jz NoDrop2
	Call DropEqual
NoDrop2:
	pop cx si
	mov ax,di
	sub ax,si
	mov es:[si],ax			; Размер запакованных данных
	mov es:[si][2],cx		; Распакоыванных
	ret
RLEP	endp

DropEqual	proc			; Скидываем похожие
	push ax
	mov al,bh
	add al,127
	stosb
	mov al,dl
	stosb
	mov bh,0
	mov ax,si
	dec ax
	mov NoMatched,ax
	pop ax
	ret
DropEqual	endp

DropNotEqual	proc			; Скидываем не похожие
	push si cx ax
	mov al,bl
	stosb
	mov si,NoMatched
	xor cx,cx
	mov cl,bl
rep	movsb
	mov bl,0
	mov NoMatched,si
	pop  ax cx si
	ret
DropNotEqual	endp

NoMatched	dw	?
