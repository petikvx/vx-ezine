;
; Лечилка для SUBURBS-393 в памяти
;
SigLen	EQU	14
;
Start:
; ============== Обязательная часть =================
        jmp     Dalee
	db	'(M)'
Ident	db	' SUBURBS-393',0
Flag	dw	0
;
Dalee:
	db	60h
	push	ds
	push	es
	call	Next
Next:
	pop	bp
	sub	bp, offset Next - (offset Start+100h)
	mov	cs:Flag[bp], ax
; ===================================================
; Устанавливаем сегменты
	push	20h
	pop	es
	push	cs
	pop	ds
; Сравниваем на сигнатуру
	lea	si, Signat[bp]
	sub	di, di
	mov	cx, SigLen
Compar:
	lodsb
	cmp	al, es:byte ptr [di]
	jnz	MemOK
	inc	di
	loop	Compar
; Лечить?
	cmp	Flag[bp], 1
	jnz	MemBad
; Забиваем память NOP-ами
	mov	al, 90h
	mov	di, 6
	mov	cx, 5
	cli
	rep	stosb
	sti
; Выдаем сообщение
	mov	ah, 9
	cmp	cs:Flag[bp], 1
	jnz	NoCured
Cured:
	lea	dx, Messag1[bp]
	jmp	Print
NoCured:
	lea	dx, Messag2[bp]
Print:
	int	21h
MemBad:
	stc
	jmp	Ready
; Завершаем работу
MemOK:
	clc
Ready:
; ============== Обязательная часть =================
	pop	es
	pop	ds
	db	61h
	db	0CAh, 02, 00
; ===================================================
Messag1 db      'Вирус SUBURBS-393 в памяти обезврежен!', 13, 10, '$'
Messag2 db	'Вирус SUBURBS-393 в памяти!', 13, 10, '$'
Signat  db      0E9h, 0EDh, 000h, 0B0h, 003h, 0CFh, 080h
	db	0FCh, 04Bh, 074h, 003h, 0E9h, 0DDh, 000h
        db
        End     Start