; При входе в процедуру,DS:Si - смещение на проверяемый код
;			ES:BX - текущая сигнатура

loc_quit:	retf

tester		proc	far
		xor	ax,ax
		mov	word ptr cs:[48h],ax	; Очистим некоторые переменные
		mov	word ptr cs:[58h],ax
		mov	word ptr cs:[5Ah],ax
		mov	word ptr cs:[5Ch],ax
		mov	word ptr cs:[5Eh],ax
		mov	word ptr cs:[54h],ax
		mov	word ptr cs:[56h],ax

		mov	cx,10h			; Вычеслим CRC для 16 байт
		call	CRC
		mov	word ptr cs:[40h],ax
		mov	word ptr cs:[42h],dx

		mov	cx,20h			; Вычеслим CRC для 32 байт
		call	CRC
		mov	word ptr cs:[44h],ax
		mov	word ptr cs:[46h],dx

		nop
loc_1:
		mov	ax,es:[bx]		; Берем байт сигнатуры в AL
						; (тут небольшая оптимизация)
		cmp	ax,0FFFFh		; = - 1?
		je	loc_quit		; На выход
		mov	di,es:[bx+1]		; Берем смещение
		add	di,si			; Добавили текущую позицию
		cmp	al,[di]			; Сравнили байт
		jne	loc_6			; Не похож ?
		mov	cl,es:[bx+3]		; Cl - размер сигнатуры
		cmp	si,di			; SI = DI ? Если равны,то
						; считать CRC не надо - он
						; уже подсчитан
		jne	loc_3			; Нет...Подсчитать нужно

		cmp	cl,10h			; А размер случайно меньше 16 ?
		jb	loc_3			; Меньше...Считать придется...
		jnz	loc_2			; Неа...не меньше,но и не 16.
		mov	ax,word ptr cs:[40h]	; Возьмем подсчитанный раньше
		mov	dx,word ptr cs:[42h]	; CRC
		jmp	short loc_5		; На сравнение
loc_2:
		cmp	cl,20h			; А длина случайно не 32 байта?
		jne	loc_3			; Нет....Считаем
		mov	ax,word ptr cs:[44h]	; Да. Мы такое уже считали.
		mov	dx,word ptr cs:[46h]	; сравниваем...
		jmp	short loc_5
loc_3:
		xor	ax,ax			; Очистим AX и DX
		mov	dx,ax

		xchg	bx,bx			; ????
loc_4:
		xor	dh,dl			; Цикл CRC
		xor	dl,ah
		xor	ah,al
		mov	al,[di]
		inc	di
		xor	al,dh
		dec	cl			; Счетчик уменьшили на 1
		jnz	loc_4			; = 0 ?
loc_5:
		mov	cx,100h			; Включим подозрение на 
						; модификацию какого-то вируса
		cmp	ax,es:[bx+4]
		jne	loc_6			; Первый кусок CRC
		cmp	dx,es:[bx+6]
		je	loc_7			; Второй кусок CRC

		xchg	bx,bx			; ??? Lameness !
loc_6:
		xor	cx,cx			; Cx = 0. Сняли подозрение
		cmp	byte ptr cs:[70h],1	;
		je	loc_9			;
		cmp	byte ptr es:[bx+3],0Ah
		jb	loc_9			;
loc_7:
		add	cl,es:[bx+0Bh]		; Мы его словили ! Половина
		jz	loc_12			; сигнатуры есть. Еще одна
						; половина есть в базе ?
		mov	dl,es:[bx+8]		; Есть. DL - байт второй 
						; сигнатуры
		mov	di,es:[bx+9]		; Di - смещение сигнатуры
		add	di,si			; добавили смещение
		cmp	dl,[di]			; Сравнили
		je	loc_10			; Есть !
loc_8:
		cmp	ch,1			; Есть подозрение о вирусе ?
		je	loc_13			; Да...Осведомим юзера
loc_9:
		mov	di,es:[bx+10h]		; Взяли тип сигнатуры
		and	di,0Fh			; оставим 4 бита
		add	di,di			; умножим на 2
		add	bx,cs:data_16e[di]	; добавим размер данного блока
		jmp	loc_1			; из таблицы и на следующюю
						; сигнатуру
loc_10:
		xor	ax,ax			; Очистим AX и DX
		mov	dx,ax
		nop
loc_11:
		xor	dh,dl
		xor	dl,ah
		xor	ah,al
		mov	al,[di]
		inc	di
		xor	al,dh
		dec	cl
		jnz	loc_11			; Снова считаем сигнатуру

		cmp	ax,es:[bx+0Ch]
		jne	loc_8			; И тут равно ?
		cmp	dx,es:[bx+0Eh]
		jne	loc_8			; Батенька,да у вас вирус !
loc_12:
		cmp	ch,1
		je	loc_14			; Все...Пугаем юзера

		mov	al,es:[bx+0Bh]		; Взяли размер второй сигнатуры
		cmp	al,10h
		jb	loc_9			; < 16 ?

		cmp	al,30h			; > 48 ?
		ja	loc_9

loc_13:
		mov	al,es:[bx+3]		; Берем размер первой сигнатуры
		cmp	al,0Ah
		jb	loc_9			; < 10 ?

		cmp	al,30h			; > 48 ?
		ja	loc_9

		test	byte ptr es:[bx+10h],30h; Проверим какой-то бит
						; чего-то....
		jnz	loc_9			; Стоит

		call	$+4993h			; Сюда у меня никогда управление
						; не попадало.

		jmp	short loc_9		; След. сигнатура
loc_14:
		mov	ax,es:[bx+11h]		; Переписываем нужные значения
		mov	word ptr cs:[80h],ax

		mov	ax,es:[bx+13h]		; Какое-то из них номер имени
						; вируса в таблице,какое-то
		mov	word ptr cs:[82h],ax	; размер оного и тп...

		mov	ax,es:[bx+15h]
		mov	word ptr cs:[84h],ax

		test	byte ptr es:[bx+10h],30h;Глюк ?
		jnz	Quit			; На выход.

		callf	ShowMsg			; Пугаем юзера !
		jnc	$+73h			; Надо лечить ?
		mov	sp,bp
Quit:
		retf				; Return far

tester		endp
