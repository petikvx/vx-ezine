; Сжатие по LZ78
;  Я не старался делать очень быструю штукенцию - главное что-бы работало.
;  В принципе можно неплохо оптимизировать (и по скорости и по размеру).
;  LZ78 бинарные файлы сжимает плохо
;  Как это все работает - читайте мою статейку о алгоритмах сжатия.
;  Распаковка работает намного быстрее чем упаковка
;  Степень сжатия средняя. (Хуже чем PkZip на ~40% :)

; Deviator/HAZARD.

BitLim	equ	12			; Макс. размерность кода. Чем больше
					; тем лудше степень сжатия но и памяти
					; требуется больше,и работает в n-раз
					; медленнее

LZ78c	proc		; Ds:Si - Source; Es:Di - Dest; Cx - Length
			; Так как это только демонстрация,то словарь лежит в
			; нашем кодовом сегменте.
	push di
	mov cs:[Dictnum],0		; Размер словаря
	mov 1 ptr cs:[Dict],0		; Длина 0го элемента
	mov bx,di			; Сохраняем в Bx Di
	mov di,offset P			; Di - на нашу строку
	mov cs:[DictBit],1		; Начальное кол-во бит для кода
	mov cs:[DictLim],2		; 2^1 = 2
        xor bp,bp
Pack:	lodsb				; Берем байт
	mov cs:[di],al			; Добавляем его в строку
	inc di

	dec cx
	cmp cx,0			; Есть еще байты ?
	jle Packed

	Call FindInDict			; Да...Ищем строку в словаре
	jc Pack				; Есть такая...Добавим еще один символ

	dec di				; Строки с последним добавленным байтом
	Call FindInDict			; нету..Ищем номер строки без оного.
	inc di				; Восстановим длину

	push ax
	xchg ax,dx			; Сохраним код строки
	Call StoreCode
	pop  ax
	Call StoreByte			; Сохраним байт который не входил в
					; данную строку

	Call AddEntry			; Добавим в словарь всю строку

	mov di,offset P			; Длина строки = 0
	jmp Pack			; Поехали

Packed:	dec  di
	Call FindInDict			; Все сделали,но в строке остались
					; символы...Запишим их
	push ax
	xchg ax,dx
	Call StoreCode
	pop  ax
	Call StoreByte

	mov ax,cs:[DictLim]		; Запишим конец кода
	dec ax
	Call StoreCode

	mov ax,bp			; Расчитаем длину
	xor dx,dx
	mov cx,8
	div cx
	inc ax
	add ax,bx
	pop cx
	sub ax,cx
	xchg ax,cx

	ret
LZ78c	endp

LZ78u	proc				; Распаковка. Ds:Si - упакованные данные
					; Es:Di - куда ложить распакованное
	push di				; Сохраним Di
	mov cs:[DictNum],0		; Проинициализируем словарь
	mov 1 ptr cs:[Dict],0
	mov bx,di
	mov di,offset P
	mov cs:[DictBit],1
	mov cs:[DictLim],2
	xor bp,bp
UnPack:	Call GetCode			; Берем код
	push ax
	Call GetByte			; Берем байт за кодом
	pop  dx
	inc dx				; Увеличим код на 1
	cmp cs:[DictLim],dx		; Равен лимиту ?
	jz xDone			; Да. Это был код окончания потока кода
	dec dx				; Undo
	Call StoreString		; Перепишим в строку последовательность
					; соответствующюю коду в Dx
	mov cs:[di],al			; Добавим в конец Al
	inc di
	Call AddEntry			; Добавим в словарь строку

	push si ds cs			; Скидываем строку по назначению
	pop  ds

	mov si,offset P			; Si - строка
	xchg bx,di			; Di - куда
	mov cx,bx
	sub cx,si			; Cx - размер (мин. 1)
rep	movsb
	xchg bx,di
	mov di,offset P			; Длина строки = 0
	pop ds
	pop si
	jmp UnPack			; Распаковываем

xDone:	pop cx				; Расчитываем новый размер
	sub cx,bx
	neg cx
	ret
LZ78u	endp

StoreString	proc			; Преобразовываем код в строку
	push ax cx si ds es cs cs	; Жуткая цепочка Push'ов
	pop  es ds
	or dx,dx			; Код = 0 ?
	jz EmptyString
	mov cx,dx
	xor ax,ax
	mov si,offset Dict		; Нет...Ищем в словаре
xFind:	lodsb
	add si,ax
	loop xFind
	lodsb				; Берем длину
	xchg ax,cx
rep	movsb				; Пишем саму строку
EmptyString:
	pop  es ds
	pop  si cx ax
	ret
StoreString	endp
;-----------------------------
FindInDict	proc			; Процедурка поиска в строке
	push ax cx si di es ds cs cs	; Жуткие (и тормозные) Push'и
	pop  ds es
	mov dx,di
	sub dx,offset P
	cmp dl,255			; Длина = 255 ?
	jz NotInDict			; Да. Говорим что нету в словаре,
					; а значит не будет переполнения

	mov cx,DictNum			; Размер словаря
	cmp cx,0
	jle NotInDict			; <= 0 ?

	mov di,offset P			; Нет...Ищем в словаре
	mov si,offset Dict
	inc cx
FindIt:	push cx di
	xor ax,ax
	lodsb
	xchg ax,cx
	cmp cx,dx			; Длина совпадает ?
	jnz NChar
rep	cmpsb				; Да. Сравниваем
NChar:	pushf
	add si,cx
	popf	
	pop  di cx
	jz InDict			; Нашли !
	loop FindIt			; Нет..
NotInDict:
	clc
	pop ds es
	pop di si cx ax			; Восстанавливаем регистры
	xor dx,dx
	ret
InDict:	mov dx,DictNum			; Нашли
	sub dx,cx			; Расчитаем позицию
	inc dx
	pop ds es
	pop di si cx ax
	stc
	ret
FindInDict	endp
;-----------------------------
AddEntry	proc			; Добавим в словарь строку
	push ax si di cx ds es cs cs	; Arggh !
	pop  es ds
	mov si,offset Dict
	inc [DictNum]			; Увеличим кол-во строк в словаре
	mov ax,DictNum			; Сравним с Лимитом-1
	inc ax
	cmp ax,DictLim			; Меньше ?
	jb  LimOk			; Да...
	shl [DictLim],1			; Нет... Умножим лимит на 2
	inc [DictBit]			; Увелиим кол-во бит
	cmp [DictBit],BitLim		; Кол-во бит > BitLim (13) ?
	jb LimOk			; Нет
	mov [DictNum],0			; Да. Проинициализируем словарь
	mov [DictBit],1
	mov [DictLim],2
	mov ax,1
LimOk:	xchg ax,cx			; Пропускаем
	xor ax,ax
Skip:	lodsb
	add si,ax
	loop Skip
NoSkip:	mov ax,di
	sub ax,offset P			; Пишим длину строки
	xchg si,di
	stosb
	xchg ax,cx
	mov si,offset P
rep	movsb				; Саму строку
	pop  es ds
	pop  cx di si ax
	ret
AddEntry	endp
;-----------------------------
StoreCode	proc			; Процедурка записывающая из Ax 
					; DictBit бит в выходной поток
	push cx dx
	mov cx,cs:[DictBit]
	xor dx,dx
StoreIt:bt ax,dx			; Стоит бит #dx ?
	inc dx
	jnc DropBit			; Нет...Скинем в выходном потоке
					; соответствующий
	bts es:[bx],bp			; Стоит...Установим...
	jmp NBit
DropBit:btr es:[bx],bp
NBit:	inc bp
	cmp bp,8000h
	jb nLim
	sub bp,8000h
	add bx,1000h
nLim:	loop StoreIt			; След

	pop dx cx
	ret
StoreCode	endp
;-----------------------------
StoreByte	proc			; Аналогично StoreCode,но ложится
					; стабильно 8 бит
	push cx dx
	mov cx,8
	xor dx,dx
Store8:	bt ax,dx
	inc dx
	jnc xdBit
	bts es:[bx],bp
	jmp xnBit
xdBit:	btr es:[bx],bp
xnBit:	inc bp
	cmp bp,8000h
	jb zLim
	add bx,1000h
	sub bp,8000h
zLim:	loop Store8
	pop dx cx
	ret
StoreByte	endp
;-----------------------------
GetCode	proc				; Берем из входного потока DictBit
					; бит
	push cx dx
        xor ax,ax
	mov cx,cs:[DictBit]
	xor dx,dx

zIt:    bt ds:[si],bp
	inc bp
	jnc  bDBit
	bts ax,dx
	jmp bNBit
bDBit:  btr ax,dx
bNBit:	inc dx
	cmp bp,8000h
	jb XLim
	sub bp,8000h
	add si,1000h
XLim:	loop zIt

	pop dx cx
	ret
GetCode	endp
;-----------------------------
GetByte	proc				; Берем из входного потока 8 бит
	push cx dx
	mov cx,8
	xor dx,dx

zGet8:	bt ds:[si],bp
	inc bp
	jnc zDBit
	bts ax,dx
	jmp znBit
zdBit:	btr ax,dx
znBit:	inc dx
	cmp bp,8000h
	jb  LLim
	add si,1000h
	sub bp,8000h
LLim:	loop zGet8

	pop dx cx
	ret
GetByte	endp
;-----------------------------

P	db	127 dup (?)			; Строка

DictBit	dw	?				; Кол-во бит
DictLim	dw	?				; Лимит

DictNum	dw	?				; Размер словаря
Dict	db	30000 dup (?)			; Словарь с запасом размера
