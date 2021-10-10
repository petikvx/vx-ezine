;
; Лечилка для SEEYOU.B на харде
;
Start:
; ============== Обязательная часть =================
        jmp     Dalee
	db	'(H)'
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
; Читаем boot-сектор харда
	mov	dx, 180h
        mov     ax, 0201h
	mov	cx, 1h
	push	cs
	pop	es
	push	cs
	pop	ds
	lea	bx, cs:Buf[bp]
	call	Int13
	jnc	OK1
	jmp	Err
OK1:
; Сравниваем на сигнатуру
	mov	cx, 6
	lea	si, cs:Sign[bp]
	lea	di, cs:Buf[bp]
ChkHDD:
	mov	al, cs:byte ptr [di+0FAh]
	mov	ah, cs:byte ptr [si]
	cmp	ah, al
	jz	Contin
	jmp	OkHDD
Contin:
	inc	si
	inc	di
	Loop	ChkHDD
; Дополнительный контроль
	cmp	cs:byte ptr Buf[bp+6Dh], 0BAh
	jnz	NewVir
	cmp	cs:byte ptr Buf[bp+70h], 0B9h
	jnz	NewVir
; Определяем местоположение спрятанного сектора
	mov	dx, cs:word ptr Buf[bp+6Eh]
	mov	cx, cs:word ptr Buf[bp+71h]
	inc	cx	; Нужен следующий сектор !!!
; Читаем его
RdSave:
	mov	ax, 201h
	lea	bx, cs:Buf[bp]
	Call	Int13
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
; Лечить?
	cmp	cs:Flag[bp], 1
	jnz	SkipCure
; Записываем в BOOT
	mov	ax, 301h
	mov	dx, 180h
	mov	cx, 1h
	lea	bx, cs:Buf[bp]
	call	Int13
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
OkHDD:
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
Int13:
	mov	si, 3
Rep13:
	push	ax
	int	13h
	jnc	Ok13
	sub	ax, ax
	int	13h
	pop	ax
	dec	si
	cmp	si, 0
	jnz	Rep13
Bad13:
	stc
	ret
Ok13:
	pop	ax
	clc
	ret
Ready:
; ============== Обязательная часть =================
	pop	es
	pop	ds
	db	0CAh, 02, 00
; ===================================================
Messag1 db	'HDD болен SEEYOU.B и исцелен', 13, 10, '$'
Messag2 db	'HDD болен SEEYOU.B',13, 10, '$'
Messag3 db      ' - ошибка доступа',13, 10, '$'
Messag4 db	'HDD болен модификацией SEEYOU', 13, 10, '$'
Sign	db	06h, 057h, 0CBh, 02Eh, 088h, 026h
Buf	db	512 dup (0)
	End	Start