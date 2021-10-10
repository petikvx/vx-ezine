; Простой шифровщик. Зачем мне мучатся, и вставлять его как inline ?
; Просто компилю,переименновываю в decrypt.bin и компилирую crypted.c--

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