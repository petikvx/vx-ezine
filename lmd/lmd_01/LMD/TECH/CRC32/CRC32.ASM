; Подсчет CRC32 by
; Alex Morshchakin AKA Scout
; Alexander Kopec AKA KAA
; Scientific Programming Society, 1995

_CODE           SEGMENT PARA    PUBLIC  'Code'
		ASSUME	cs:_CODE, ds:_CODE, es:_CODE
		JUMPS

		ORG	80h

Com_Line_Size	db	?
Com_Line	LABEL	BYTE

		ORG	100h
Start:
		call	Parsing
		jc	Finish

		mov	ax, 3D00h
		int	21h
		jnc	Open_OK

		mov	dx, OFFSET Open_Msg
		jmp	Finish
Open_OK:
		mov	FHandler, ax
		call	CRC_Init

Next_File_Page:
		mov	dx, OFFSET Buffer
		mov	cx, 8000h
		mov	bx, FHandler
		mov	ah, 3Fh
		int	21h
		jnc	Read_OK

		mov	dx, OFFSET Read_Msg
		jmp	Finish
Read_OK:
		or	ax, ax
		jz	EOF

		mov	cx, ax
		call	CRC
		jmp	Next_File_Page
EOF:
		mov	bx, FHandler
		mov	ah, 3Eh
		int	21h

		mov	si, OFFSET File_CRC+3
		mov	di, OFFSET OK_Msg+10
		mov	cx, 4
		mov	bx, OFFSET Hex
		mov	ah, 2
Next_Digit:
		std
		lodsb
		push	ax
		shr	al, 1
                shr     al, 1
                shr     al, 1
                shr     al, 1
		xlat
		cld
		stosb
		pop	ax
		and	al, 00001111b
		xlat
		stosb
		loop	Next_Digit

		mov	dx, OFFSET OK_Msg
Finish:
		mov	ah, 9
		int	21h
		mov	ax, 4C00h
		int	21h

Parsing 	PROC	NEAR
		mov	si, OFFSET Com_Line_Size
		lodsb
		cbw
		mov	cx, ax
Next_Blank:
		jcxz	Com_Line_Error
		lodsb
		dec	cx

		cmp	al, ' '
		je	Next_Blank
		cmp	al, 9
		je	Next_Blank

		mov	dx, si
		dec	dx
Next_Char:
		lodsb
		jcxz	Put_Zero
		dec	cx
		cmp	al, ' '
		je	Put_Zero
		cmp	al, 9
		jne	Next_Char
Put_Zero:
		mov	BYTE PTR [si-1], 0

Next_Tail:
		jcxz	Com_Line_OK
		lodsb
		dec	cx

		cmp	al, ' '
		je	Next_Tail
		cmp	al, 9
		je	Next_Tail
Com_Line_Error:
		mov	dx, OFFSET Syntax_Msg
		stc
		retn
Com_Line_OK:
		clc
		retn
Parsing 	ENDP

CRC_Init	PROC	NEAR
		mov	di, OFFSET CRC_Table
		xor	bx, bx
Next_I:
		xor	ax, ax
		mov	dx, ax
		mov	al, bl

		mov	cx, 8
Next_J:
		shr	dx, 1
		rcr	ax, 1
		jnc	Dec_J
		xor	dx, 0EDB8h
		xor	ax, 08320h
Dec_J:
		loop	Next_J

		stosw
		mov	ax, dx
		stosw
Inc_I:
		inc	bx
		cmp	bx, 256
		jb	Next_I

		retn
CRC_Init	ENDP

CRC		PROC	NEAR
		mov	si, OFFSET Buffer
		mov	ax, WORD PTR File_CRC
		mov	dx, WORD PTR File_CRC+2
Next_Byte:
		xor	bx, bx
		mov	bl, al
		lodsb
		xor	bl, al
		shl	bx, 1
                shl     bx, 1

		mov	al, ah
		mov	ah, dl
		mov	dl, dh
		xor	dh, dh

		xor	ax, WORD PTR CRC_Table[bx]
		xor	dx, WORD PTR CRC_Table[bx+2]

		loop	Next_Byte

		mov	WORD PTR File_CRC, ax
		mov	WORD PTR File_CRC+2, dx
		retn
CRC             ENDP


Hex		db	'FEDCBA9876543210'

File_CRC        dd      0FFFFFFFFh

Syntax_Msg      db      13, 10, 'Syntax error.'
		db	13, 10, 'Usage: CRC32 FileName', 13, 10, '$'
Open_Msg	db	13, 10, 'File open error.', 13, 10, '$'
Read_Msg	db	13, 10, 'File read error.', 13, 10, '$'

OK_Msg		db	13, 10, 'CRC32 =         h', 13, 10, '$'

FHandler        dw      ?

CRC_Table       dd      256     dup     (?)

Buffer		LABEL	BYTE

_CODE		ENDS

		END	Start
