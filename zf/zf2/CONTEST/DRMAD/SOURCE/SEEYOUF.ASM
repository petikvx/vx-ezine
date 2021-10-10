;
; Лечилка для SEEYOU.B на флопах
;
Start:
; ============== Обязательная часть =================
        jmp     Dalee
	db	'(F)'
Ident	db	' SEEYOU.B',0
Flag	dw	0
Drive	dw	0
;
Dalee:
	push	ds
	push	es
	call	Next
Next:
	pop	bp
	sub	bp, offset Next - (offset Start+100h)
	mov	cs:Flag[bp], ax
	mov	cs:Drive[bp], bx
; ====================================================
; Читаем boot-сектор дискеты
	mov	dx, cs:Drive[bp]
        mov     ax, 0201h
	mov	cx, 1
	push	cs
	pop	es
	push	cs
	pop	ds
	lea	bx, cs:Buf[bp]
	call	Int40
	jnc	OK1
	jmp	Err
OK1:
; Сравниваем на сигнатуру
	mov	cx, 6
	lea	si, cs:Sign[bp]
	lea	di, cs:Buf[bp]
ChkFDD:
	mov	al, cs:byte ptr [di+0FAh]
	mov	ah, cs:byte ptr [si]
	cmp	ah, al
	jz	Contin
	jmp	OkFDD
Contin:
	inc	si
	inc	di
	Loop	ChkFDD
; Определяем тип дискеты
	mov	al, cs:byte ptr Buf[bp+16h]
	cmp	al, 2
	jz	d360
	cmp	al, 7
	jz	d1200
	cmp	al, 3
	jz	d720
	cmp	al, 9
	jz	d1440
	jmp	Err
; Рассчитываем местоположение спрятанного сектора
d360:
	mov	cx, 2
	jmp	RdSave
d1200:
	mov	cx, 13
	jmp	RdSave
d720:
	mov	cx, 4
	jmp	RdSave
d1440:
	mov	cx, 14
RdSave:
	mov	ax, 201h
	mov	dx, cs:Drive[bp]
	mov	dh, 1
	lea	bx, cs:Buf[bp]
	Call	Int40
	jc	Err
; Расшифровываем спрятанный сектор
	push	bx
	mov	ax, 506Fh
	mov	cx, 1FFh
LL:
	xor	es:[bx], ax
	add	ax, 7075h
	inc	bx
	loop	LL
	pop	bx
; Дополнительный контроль
	cmp	cs:byte ptr Buf[bp], 0E9h
	jz	IsBoot
	cmp	cs:byte ptr Buf[bp], 0EBh
	jz	IsBoot
	jmp	NewVir
IsBoot:
; Лечить?
	cmp	cs:Flag[bp], 1
	jnz	SkipCure
; Записываем в BOOT
	mov	ax, 301h
	mov	dx, cs:Drive[bp]
	mov	cx, 1
	lea	bx, cs:Buf[bp]
	call	Int40
; Вылечили
	mov	ah, 9
	lea	dx, Messag1[bp]
	int	21h
	stc
	jmp	Ready
; Ошибка
Err:
	mov	ah, 9
	lea	dx, Messag3[bp]
	int	21h
	clc
	jmp	Ready
; Здоровый
OkFDD:
	clc
	jmp	Ready
; Неизвестный
NewVir:
        mov     ah, 9
	lea	dx, Messag4[bp]
	int	21h
	clc
	jmp	Ready
; Не лечим :-(
SkipCure:
	mov	ah, 9
	lea	dx, Messag2[bp]
	int	21h
	stc
	jmp	Ready
; ============= Процедура "грамотного" Int13 =========
Int40:
	mov	si, 3
Rep40:
	push	ax
	int	40h
	jnc	Ok40
	sub	ax, ax
	int	40h
	pop	ax
	dec	si
	cmp	si, 0
	jnz	Rep40
Bad40:
	stc
	ret
Ok40:
	pop	ax
	clc
	ret
Ready:
; ============== Обязательная часть =================
	pop	es
	pop	ds
	db	0CAh, 02, 00
; ===================================================
Messag1 db	'FDD болен SEEYOU.B и исцелен', 13, 10, '$'
Messag2 db	'FDD болен SEEYOU.B',13, 10, '$'
Messag3 db      'FDD ошибка доступа',13, 10, '$'
Messag4 db	'FDD болен модификацией SEEYOU', 13, 10, '$'
Sign	db	06h, 057h, 0CBh, 02Eh, 088h, 026h
Buf	db	512 dup (0)
        End     Start