; Deviator's Huffman Encoding/Deconing Engine

; Да ! Вот я и накодил Хаффмана !
;  Скажем это не совсем Хаффман,скорее полу-Хаффман....дерево то нету :)
;  Посидел я с листиком и карандашом,построил наиболее оптимальное дерево,
;  посмотрел закономерности и написал данную прогу.

; Размер упаковщика:	~340 байт
; Распаковщика:		~90  байт
;  Размер распаковщика можно укоротить байт на 30

; Наиболее оптимальное дерево:
;		 
;		/^\
;	      /     \
;	    /\	     /\
;	   /  \     /  \
;         /\  /\   /\  /\
; и так далее...
;  Так вот если мы построим такое дерево до конца,то в результате мы просто
; получим таблицу замены байт на байт. Значит надо где-то укоротить длину кода,
; а где-то увеличить. 

;	       /^\
;	      /   \
;	     /    /\		- Ветвь из 2 элементов
;	    /\   /  \
;	   /  \
;	  /    \
;	 /     /\		- Элементы удваиваются - 4 элемента
;       /     /   \
;      /     /\    /\
;     /     /  \  /  \ 
; и так далее... Получается наиболее оптимальное распределение кода.
; Естественно,чем меньше различных байт,тем лудше. Например наибольшая длина
; ветви для 2-начинающих элементов составляет 14 бит:

; 2 бита  = 2   элемента
; 4 бита  = 4   элемента
; 6 бит   = 8   элементов
; 8 бит   = 16  элементов
; 10 бит  = 32  элемента
; 12 бит  = 64  элемента
; 14 бит  = 128 элементов
;           ---
;	    256

; Естественно,если в начинающей ветви один элемент, то потребуется больше 
; бит для всего дерева(15). Соответственно,чем в файле меньше используется
; различных символов, тем меньше нужно делать первую ветвь.

; Максимальная степень сжатия по Хаффману 1:8 (при файле состоящем из одних
;  и тех-же символов и с начальной ветвью в один элемент).

; Обычно наилудшие результаты дает начальная ветвь из 4 элементов. Максимальная
;  степень сжатия - 2:1. Можно,в принципе,от количества различных символов
;  изменять первоначальную ветвь,но я пока просто прописал ее размер константой.

; В среднем степень сжатия хуже чем у LZ77,но бывают просветы,когда Хаффман
;  сжимает очень даже неплохо.

; P.S.	   Лудше всего применять в совокупности с RLE
; P.S.S.   Размер меньше,сжимает лудше,быстрее чем асмовый пример Z0MBiE :)
;	   (в зависимости от подсунутого файла и настройки BitLim)
; P.S.S.S. Кто-то мне на #vir говорил что он крутой,и что он написал Huffman 
;	   паковщик/распаковщик в ~700/600 байт. Причем он мне пытался доказать
;          что Хаффман у него сжимает в соотношении больше чем 8:1,только вот
;	   об'яснить почему он так сжимает, не смог :)

BitLim	=	4			; Количество элементов в первой ветви
NumLim	=	1 shl (BitLim-1)	; Аналогично,но в числе

Huffe	proc	; DS:Si - Source, ES:Di - Dest; Returns new size in CX (bytes)
	pusha
	mov bp,sp

	mov ax,cx			; Сохраним размер
	stosw

	push di
	mov cx,256
	xor eax,eax
	mov di,offset EncTbl
	push di
FillTbl:				; Заполним таблицу
	stosd
	inc ax
	loop FillTbl

	mov cx,[bp][12]
	pop  di
Count:	xor ax,ax			; Производим статистику появления того
	lodsb				; или иного символа
	shl ax,2
	xchg ax,bx
	inc 2 ptr ds:[di][bx][1]
	loop Count

	mov cx,255			; Газируем :)
Sort:	push cx	

	mov ax,255			; Вычислим кол-во циклов
	sub cx,ax
	add ax,cx
	xchg ax,cx

	mov si,di
Inner:	mov ebx,ds:[si]			; Идет сортировка
	mov ax,ds:[si][1]
	cmp 2 ptr ds:[si][4][1],ax
	jbe NoXchange
	xchg ebx,ds:[si][4]
	mov  ds:[si],ebx
NoXChange:
	add si,4
	loop Inner
NoSort:	pop  cx
	loop Sort
					; Теперь у нас есть точная статистика
	xchg si,di
	mov  di,offset HufTbl		; Перепишем символы в таблицу
	mov  cx,256
	xor  bx,bx			; Bx возьмем как счетчик кол-ва букв
CopySym:movsb				; Копируем букву
	lodsw				; Берем размер. 
	or ax,ax			; Все, приехали ?
	jz Copied
	inc bx
	inc si
	loop CopySym			; Дойдем до конца
Copied:	mov F,bx			; Сохраним кол-во
	xchg ax,bx
	pop di
	stosw				; Кидаем в поток кол-во символов

	mov  si,offset HufTbl
	xchg ax,cx
rep	movsb				; Переписываем в выходной поток символы
	push di
	
        Call GenTree			; Создадим псевдо-дерево

	pop di
	mov si,[Bp][2]
	mov cx,[Bp][12]

	xor bp,bp
Pack:	lodsb				; Возьмем байт
	xchg ax,dx			; Сохраним байт в DL

	push si cx
	mov  si,offset HufTbl		; Ищем в таблице (отсортированной)
	mov  cx,F
	xor  bx,bx
FindIt:	lodsb
	cmp al,dl
	jz  SameChar			; Нашли ?
	inc bx
	loop FindIt

SameChar:			; Нашли... В BX хранится номер символа в таблице
	mov si,bx
	shl si,1			; Умножим на 2
	mov ax,2 ptr [si][EncTbl]	; Берем код замены для данного символа
	bsr cx,ax			; Нужное кол-во бит для представления
					; кода
	jz  Zero			; Вообще бит нету ?
	cmp cx,BitLim			; < BitLim ?
	jae Break
Zero:	mov cx,BitLim-1			; No comment
Break:	inc cx				; Увеличим на 1
BitStore:				; Сохраняем код в выходном потоке
	dec cx				; Отнимем 1
	bt  ax,cx			; Бит стоит ?
	jc SetBit			; Стоит...
	btr [di],bp			; Не стоит,очистим
	jmp SBit
SetBit:	bts [di],bp			; Поставим
SBit:	inc bp				; След. бит
	cmp bp,8000h			; > 8000h бит ?
	jb SBitOk			; Все нормально
	xor bp,bp			; Бит = 0
	add di,4096			; Добавим 4096 байт
SBitOk:	or  cx,cx			; Есть еще биты ?
	jnz BitStore
PNChar:
	pop  cx si
	loop Pack			; Есть еще байты ?

	mov ax,bp			; Расчитаем новый размер
	xor dx,dx
	mov cx,8
	div cx
	inc ax				; Получим кол-во байтов
	add ax,di
	mov bp,sp
	sub ax,[bp][0]
	mov [bp][12],ax			; Сохраним новый размер

	popa
	ret
Huffe	endp
Huffel	equ	$ - Huffe
;---------------------------------------------------------------------

Huffu	proc				; Распаковщик
	pusha				; DS:Si - Src, ES:Di - Dest
	mov bp,sp			; Returns: new size in CX
	lodsw				; Берем старый размер
	mov [bp][12],ax
	add ax,di
	mov F,ax			; До куда распаковывать

	lodsw				; Кол-во различных байт
	xchg ax,cx
	mov di,offset HufTbl
rep	movsb				; Переписали соответствия
					;  байт к дереву
	mov di,[bp][0]

	xor bp,bp

Unpack:	mov bx,offset HufTbl		; Цикл распаковки (мизерный однако !)
	mov dx,NumLim
	xor ax,ax			; Ax = 0
Travel:	bt  [si],bp	                ; Берем бит
	inc bp
	pushf
	cmp  bp,8000h
	jb xOkay
	xor  bp,bp
	add si,4096
xOkay:	popf
	jnc NoBit			; Не стоит ?
	add bx,dx			; Стоит. Пропустим нужное кол-во байт
	cmp al,0			; Были уже 0-вые биты ?
	jnz xBit			; Да
	shl dx,1			; Удвоим размер ветви
	jmp dBit			; След. бит
NoBit:	mov al,1			; Уже был 0-вой бит
xBit:	shr dx,1			; Поделим размер ветви на 2
dBit:	or  dx,dx			; Дошли до конца ?
	jnz Travel			; Неа
	mov al,[bx]			; Берем байт из таблицы
	stosb				; Сохраняем
	cmp di,F			; Надо еще мучатся ?
	jb UnPack			; Надо...
	
	popa
	ret				; На выход
Huffu	endp
Hufful	equ	$ - Huffu
;-----------------------------------
GenTree proc
	mov di,offset EncTbl
	mov cx,256		; Создаем таблицу подстановки
	xor ax,ax
	xor bx,bx
	mov si,NumLim
	mov dx,BitLim
GenTbl:	push cx
	stosw			; Сохраняем значение подстановки
	inc bx
	cmp bx,si		; Превысили лимит ?
	jb  Okay		; Неа

	xor bx,bx		; Да.
	shl dh,1		; Добавим еще один еденичный бит к Bh
	or  dh,1		; Установим

	inc dl			; Кол-во бит

	shl si,1		; Лимит

Okay:	xor ax,ax
	mov ah,dh		; Старшая часть
	mov cl,8
	sub cl,dl		; Определимся со сдвигом
	or  cl,cl
	jl NoS
	shr ax,cl		; Сдвигаем
	jmp XX
NoS:	neg cl
	shl ax,cl
XX:	add al,bl		; Добавим правую часть
	pop  cx
	loop GenTbl

        ret
GenTree endp

F	dw	?
HufTbl	db	256 dup (?)
EncTbl	dd	256 dup (?)
