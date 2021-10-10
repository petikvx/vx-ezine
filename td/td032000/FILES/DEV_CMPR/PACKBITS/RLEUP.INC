; Распаковка PackBits. 32 байта

RLEUp	proc
	lodsw			; Читаем размер
	lodsw
	push ax
	add ax,di
	xchg ax,dx		; Dx - конец
	xor cx,cx
RLEUnpack:
	lodsb
	cmp al,127		; >127
	jb MakeCopy		; Меньше...Не повторяющиеся величины
	sub al,127		; -127
	xchg cl,al
	lodsb			; Размножаем байт
rep	stosb
	jmp RLEUPLoop
MakeCopy:
	xchg cl,al		; Переписываем не повторяющиеся величины
rep	movsb
RLEUPLoop:
	cmp di,dx
	jb RLEUnPack		; Достигли границы
	pop cx
	ret
RLEUp	endp
