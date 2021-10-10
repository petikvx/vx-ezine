; เจฌฅเ ญฅเฅงจคฅญโญฎฃฎ ฏซ ฃจญ . ๋ขฎคจโ ญ  ํชเ ญ ญ คฏจแ์ "Hello, World!"
; จ ฆคฅโ ญ ฆ โจ๏ ซ๎กฎฉ ชซ ขจ่จ.
;
; ฎฌฏจซจเฎข โ์ แ ฏฎฌฎ้์๎ TASM 4.1+
;
;    tasm /m example1.asm
;    tlink /x example1.obj
;    exe2bin example1.exe
;    bin2txt example1.bin example1.txt
;
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

		.286
Code		segment	use16
		assume	cs:Code, ds:Code
		org	0


Start:		pusha
		push	ds es

		push	cs 0B800h
		pop	es ds

		cld
		mov	di, 1824
		mov	si, offset Msg
		mov	ah, 01001111b
Loop$:		lodsb
		stosw
		cmp	al, 0
		jne	Loop$

		xor	ax, ax
		int	16h

		pop	es ds
		popa
		clc
		retf

Msg		db	' Hello, World!',0

Code		ends
		end	Start
