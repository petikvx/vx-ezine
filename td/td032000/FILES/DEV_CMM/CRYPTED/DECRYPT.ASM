; ���⮩ ��஢騪. ��祬 ��� ������, � ��⠢���� ��� ��� inline ?
; ���� �������,��२������뢠� � decrypt.bin � ���������� crypted.c--

.model tiny
.code
	org 100h
Main:	Call GetSi
GetSi:	pop  si
	lea si,[DecEnd-GetSi][Si]
	mov cx,0
Dc:	xor 1 ptr cs:[si],0
	inc si
	loop DC
DECEND:
End	main