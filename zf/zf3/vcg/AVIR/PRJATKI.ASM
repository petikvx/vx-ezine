;*********************************************************
;* Програмина для поиска полуморфиков                    *
;* (c) DrMad, 1997                                       *
;* Слегка модифицировано                                 *
;* (c) DrMad, 1 апреля 1999                              *
;*********************************************************
.286
Cseg	segment
	assume	cs:Cseg, ds:Cseg, ss:Cseg
	org	100h
Start:
	mov	ah, 9
	mov	dx, offset Mess1
	int	21h	
; Разбор командной строки
	cmp	byte ptr ds:[80h], 0
	jz	ReqFil
; Параметр есть
	mov	si, 82h
@3:
	mov	di, offset NamBuf
@1:	
	lodsb
	cmp	al, 0Dh ; Конец?
	jz 	EndScan
	stosb
	jmp	short @1
EndScan:
	sub	al, al
	stosb		; Пихаем 0	
	jmp	short @2
; Параметра нет, вводим строку
ReqFil:	
	mov	ah, 9
	mov	dx, offset Req
	int	21h
	mov	ah, 0Ah
	mov	dx, offset MaxLen
	int	21h
;	mov	al, 13
;	int	29h
;	mov	al, 10
;	int	29h
	mov	si, offset NamBuf
	jmp	short @3
@2:
	lea	dx, NamBuf
	call	Detect
	push	cs
	pop	ds
; ВИА "Грустные козлята" прощается с вами				
	mov	ah, 9
	mov	dx, offset Mess2
	int	21h
; Вылезаем в систему		
	mov	ah, 4Ch
	int	21h
;*********************************************************
;*      ds:dx указывает на имя проги                     *
;*********************************************************
Detect:
	push	cs
	pop	ds
	push	cs
	pop	es
; Сохранить вектор 1
	mov	ax, 3501h
	int	21h
	mov	Seg1, es
	mov	Ofs1, bx
; Установить свой обработчик Int 1
	push	dx
	mov	ax, 2501h
	mov	dx, offset Int1
	int	21h
	pop	dx
; Сохранить стек
	mov	OldSP, sp
	mov	OldSS, ss
; Восстановить ES
	push	cs
	pop	es
; Ослобонить память
	mov	ah,4Ah
	mov	bx,1001h
	int	21h
	jnc	MemOK
	jmp	MemErr
MemOK:	
; Сбросить счетчик команд
	mov	Count, 0
; Сбросить флаг окончания трассировки
	mov	StFlag, 0	
; Установить параметры
	lea	bx,BParam
	mov	SegCMS,cs
	mov	SegBP1,cs
	mov	SegBP2,cs
; Загрузить программу
        mov     ax,4B01h
	int	21h
	jc	RunErr
; Определить новорожденный PSP
	mov	ah,62h
	int	21h
	jc	PSPErr
; Сформировать точку выхода новорожденной проги
;       lea     ax,Next
;	mov	ds,bx
;	mov	ds:word ptr [0Ah],ax
;	mov	ds:word ptr [0Ch],cs
	mov	bx,Offset BParam
; Установить новый стек
	cli
	mov	ss,es:[bx+10h]
	mov	sp,es:[bx+0Eh]
	sti
; Сформировать в стеке флаги с битом T=1
	push	303h
; Сформировать в стеке точку входа
	push	es:[bx+14h]
	push	es:[bx+12h]
; Установить ES на новый PSP ( для ЕХЕ )
	mov	ax,ds
	mov	es,ax
; Сбросить регистры (это не совсем корректно)
	sub	ax,ax
	sub	bx,bx
	sub	cx,cx
	sub	dx,dx
	sub	si,si
	sub	di,di
	sub	bp,bp
; Перейти на новую программу
        iret
; Отныне запущенная программа работает
; в пошаговом режиме
Next:
; Восстановить сегментные регистры
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
; Восстановить стек
	cli
	mov	ss,ax
	mov	sp, OldSP
	sti
; Завершающие сообщения
Compl:
; Количество оттрассированных команд
	mov	al, 13
	int	29h
	mov	al, 10
	int	29h
	mov	al, '('
	int	29h
	mov	ax, Count
	call	PriNum
	mov	al, ')'
	int	29h
; Ну и каков же результат?
	cmp	cs:InFlag, 1
	jz	ItIs
ItsNot:	
	lea	dx, BAD
	jmp	Ex
ItIs:
	lea	dx, OK
	jmp	Ex	
MemErr:
	lea	dx, ME
	jmp	Ex
RunErr:
	lea	dx, RU
	jmp	Ex
PSPErr:
	lea	dx, PP
Ex:
; Вывести сообщение
        mov     ah,9
	int	21h
; Восстановить вектор 1
	mov	ax, 2501h
	mov	dx, Ofs1
	mov	ds, Seg1
	int	21h
; Завершиться
	ret
;******************************************************
;* Это обработчик трассировочного прерывания          *
;* В стеке: 1) Флаги                                  *
;*          2) CS очередной команды                   *
;*          3) IP очередной команды                   *  
;******************************************************
Int1:
; А не пора ли завершиться?
	cmp	cs:StFlag, 1
 	jnz	ConTr
        jmp	Tr	
ConTr:	
; Инкрементируем счетчик
	inc	cs:Count
; Не слишком ли много команд оттрассировано?
	cmp	cs:Count, 0FFFEh
	jb	OkCount
	jmp	StopTrace
OkCount:		
; Сохраняем все регистры
	mov	cs:word ptr RAX,AX
	mov	cs:word ptr RBX,BX
	mov	cs:word ptr RCX,CX
	mov	cs:word ptr RDX,DX
	mov	cs:word ptr RSI,SI
	mov	cs:word ptr RDI,DI
	mov	cs:word ptr RBP,BP
	mov	cs:word ptr RDS,DS
	mov	cs:word ptr RES,ES
	pushf
	pop	cs:word ptr FLAGS
; Воруем из стека адрес очередной команды
	pop	bx ; IP
	pop	es ; CS
; Все должно оставаться в стеке по-старому
	push	es
	push	bx
; Проверяем на команды изменения CS
	push	ax
	mov	ax, word ptr es:[bx]
	cmp	al, 0CDh ; int XX
	jz	StopTrace
	cmp	al, 0CCh ; int 3
	jz	StopTrace
	cmp	al, 0CFh ; iret
	jz	StopTrace
	cmp	al, 0CBh ; retf
	jz	StopTrace
	cmp	al, 0EAh ; jmp xxxx:xxxx
	jz	StopTrace
	cmp	al, 09Ah ; call xxxx:xxxx
	jz	StopTrace
	cmp	ax, 2EFFh ; jmp dptr xxxx
	jz	StopTrace
	cmp	ax, 1EFFh ; call dptr xxxx
	jz	StopTrace
	pop	ax
; Восстанавливаем все регистры	
	mov	AX, cs:word ptr RAX
	mov	BX, cs:word ptr RBX
	mov	CX, cs:word ptr RCX
	mov	DX, cs:word ptr RDX
	mov	SI, cs:word ptr RSI
	mov	DI, cs:word ptr RDI
	mov     BP, cs:word ptr RBP
	mov	DS, cs:word ptr RDS
	mov	ES, cs:word ptr RES
	push	cs:word ptr FLAGS
	popf
Tr:	
; И продолжаем трассировку	
	iret	
; Встретилась команда изменения cs. Считаем,
; что тушка уже расшифрована и можно проверять
; на сигнатуру.
StopTrace:
	pop	ax
	cmp	ah, 9
	jnz	GoodFil
; А енто такое дубовое сравнение на Игореву сигу,
; писать scasb было влом
	mov	si, dx
	cmp	ds:word ptr [si], 'iV'
	jnz	GoodFil
	cmp	ds:word ptr [si+2], 'ur'
	jnz	GoodFil
	cmp	ds:word ptr [si+4], 'Cs'
	jnz	GoodFil	
BadFil:	
	mov	cs:InFlag, 1
	jmp	short GOut
GoodFil:
	mov	cs:InFlag, 0
; Пихаем stop по адресу следующей команды
GOut:
	pop	bx
	pop	es
	push	es
	push	bx
	mov	es:[bx], 4CB4h
	mov	es:[bx+2], 21CDh
	mov	cs:StFlag, 1
;	jmp	Tr
	jmp	Next
;***********************************************
;* Суброутинка печати числа в ax               * 
;***********************************************
PriNum:
	pusha
	sub	cx, cx
LpD:
	sub	dx, dx
	mov	bx, 10
	div	bx
	push	dx
	inc	cx
	or	ax, ax
        jz      FinDiv
	jmp	LpD
FinDiv:
	pop	ax
	add	al,'0'
	int	29h
	loop	FinDiv
	popa
	retn
;************************************************
;* Блок данных                                  *
;************************************************
; Счетчик количества команд
Count	dw	0
; Признак окончания трассировки
StFlag	dw	0
; Признак совпадения сигнатуры
InFlag	dw	0
; Сохраненные регистры
RAX	dw	?
RBX	dw	?
RCX	dw	?
RDX	dw	?
RSI	dw	?
RDI	dw	?
RBP	dw	?
RDS	dw	?
RES	dw	?
Flags	dw	?
; Старое положение стека
OldSS   dw      ?
OldSP	dw	?
; Старое значение вектора 1
Ofs1	dw	?
Seg1	dw	?
; Блок параметров для запуска
BParam  dw      0
OfsCMS	dw	81h
SegCMS  dw      0
OfsBP1	dw	5Ch
SegBP1	dw	0
OfsBP2	dw	6Ch
SegBP2  dw      0
; Стек
        db      127 dup (?)
StMem	db	?
; Выводимые сообщения
Mess1	db	'***************************',13,10
	db	'* Детектируем полиморфики *',13,10
	db	'***************************$'
Mess2	db	'***************************',13,10
	db	'* Надоело детектировать   *',13,10
	db	'***************************$'	
OK	db	' Туки-туки - Игорь  !',7,13,10,'$'
BAD	db	' Усе у порадке, шeф !',13,10,'$'
ME	db	13,10,'Ошибка памяти!$'
RU	db	13,10,'Ошибка загрузки!$'
PP	db	13,10,'Ошибка определения адреса PSP!$'
Req	db	13,10,'Файл > $'
MaxLen	db	64
CurLen	db	0
NamBuf	db	64 dup (0)
Finish:
;
Cseg	Ends
	End	Start
	