;
; Лечилка для SUBURBS-393 в программах
;
VirLen  EQU     393
SigLen	EQU	14
;
Start:
; ============== Обязательная часть =================
        jmp     Dalee
	db	'(P)'
Ident	db	' SUBURBS-393',0
Flag	dw	0
;
Dalee:
	push	ds
	push	es
	call	Next
Next:
	pop	bp
	sub	bp, offset Next - (offset Start+100h)
	mov	cs:Flag[bp], ax
; ====================================================
; Открываем файл
        mov     ax, 3D02h
	int	21h
	jnc	OK1
	jmp	Err
OK1:
        mov     bx, ax
; Устанавливаем сегменты
	push	cs
	pop	ds
	push	cs
	pop	es
; Читаем 3 байта
	mov	ah, 3Fh
	mov	cx, 3
	lea	dx, B0[bp]
	int	21h
	jnc	OK2
	jmp	Err
OK2:
; Команда перехода?
	cmp	byte ptr B0[bp], 0E9h
	jz	Dalee1
	jmp	FileOk
Dalee1:
; Формируем смещение
	mov	dx, word ptr B1[bp]
	add	dx, 3
; Переходим по этому смещению
	sub	cx, cx
	mov	ax, 4200h
	int	21h
	jnc	OK3
	jmp	Err
OK3:
; Читаем гипотетическое тело вируса в буфер
	mov	ah, 3Fh
	mov	cx, VirLen
	lea	dx, cs: VirBuf[bp]
	int	21h
	jnc	OK4
	jmp	Err
OK4:
; Проверяем на сигнатуру
	lea	si, cs: VirBuf[bp]
	lea	di, cs: Signat[bp]
	mov	cx, SigLen
Compar:
	lodsb
	cmp	al, [di]
	jnz	FileOk
	inc	di
	loop	Compar
; Лечить?
	cmp	cs:Flag[bp],1
	jnz	FileBad
; Исправить в буфере байтики
	xor	cs: byte ptr VirBuf[bp+174h], 21h
	xor	cs: byte ptr VirBuf[bp+175h], 85h
	xor	cs: byte ptr VirBuf[bp+176h], 2Dh
; Перейти на начало
	mov	ax, 4200h
	sub	cx, cx
	sub	dx, dx
	int	21h
	jc	Err
; Вернуть на место байтики
	mov	ah, 40h
	mov	cx, 3
	lea	dx, VirBuf[bp+174h]
	int	21h
	jc	Err
; Перейти на позицию вируса
	mov	dx, word ptr B1[bp]
	add	dx, 3
	sub	cx, cx
	mov	ax, 4200h
	int	21h
	jc	Err
; Отсекаем файл, начиная с позиции вируса
	sub	cx, cx
	mov	ah, 40h
	int	21h
	jc	Err
; Выдать сообщение
FileBad:
        mov     ah, 9
	cmp	Flag[bp], 1
	jnz	NoCured
Cured:
	lea	dx, Messag1[bp]
	jmp	Print
NoCured:
	lea	dx, Messag2[bp]
Print:
	int	21h
;
        mov     ah, 3Eh
	int	21h
	stc
	jmp	Ready
; Завершить работу
FileOK:
	mov	ah, 3Eh
	int	21h
	clc
	jmp	Ready
; Ошибка
Err:
	mov	ah, 9
	lea	dx, Messag3[bp]
	int	21h
	jmp	FileOK
Ready:
; ============== Обязательная часть =================
	pop	es
	pop	ds
	db	0CAh, 02, 00
; ===================================================
Messag1 db	' - болен SUBURBS-393 и исцелен', 13, 10, '$'
Messag2 db	' - болен SUBURBS-393',13, 10, '$'
Messag3 db      ' - ошибка доступа',13, 10, '$'
Signat  db      0E9h, 0EDh, 000h, 0B0h, 003h, 0CFh, 080h
        db      0FCh, 04Bh, 074h, 003h, 0E9h, 0DDh, 000h
VirBuf	db	VirLen dup ('0')
B0	db	0
B1	dw	0
        End     Start