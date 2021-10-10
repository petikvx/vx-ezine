; เจฌฅเ เฅงจคฅญโญฎฃฎ ฏซ ฃจญ . จ้จโ ฏเจ ญ ฆ โจจ ซ๎กฎฉ ชซ ขจ่จ.
;
; ฎฌฏจซจเฎข โ์ แ ฏฎฌฎ้์๎ TASM 4.1+
;
;    tasm /m example2.asm
;    tlink /x example2.obj
;    exe2bin example2.exe
;    bin2txt example2.bin example2.txt
;
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

		.286
Code		segment use16
		assume  cs:Code, ds:Code
		org	0

Start:		pusha
		push	ds es

		push	cs
		pop	ds

		mov	ax, 3509h
		int	21h
		mov	ds:[Ofs09h], bx
		mov	ds:[Seg09h], es

		mov	ax, 2509h
		mov	dx, offset Int09h
		int	21h

		pop	es ds
		popa
		stc
		retf


Int09h:		pusha
		in	al, 61h
		or	al, 00000011b
		out	61h, al
		xor	cx, cx
		loop	$
		and	al, 11111100b
		out	61h, al
		popa

		db	0EAh
Ofs09h		dw	0
Seg09h		dw	0

Code		ends
		end	Start
