;-------------------- Welcome-to ------------------------;
; [$UPDû2.2], $pirit's Universal Polymorphic Device v2.2 ;
;           (C)1995-1996 by ÄNighÅÄ$piriÅÄ		 ;
;--------------------------------------------------------;
; Must compile with:					 ;
;  tasm $upddemo.asm /m					 ;
;  tlink $upddemo.obj $upd22.obj, $upddemo.com /x /t	 ;
; or use makedemo.bat for rapidly do this		 ;
;--------------------------------------------------------;

; Demo for [$UPDû2.2] engine. It will generate 20 (or another count)
; tiny polymorph-encoded progs

.MODEL TINY
JUMPS
.CODE

	org	100h
	extrn	$UPD:near	; Must declare $UPD to external module
	extrn	$UPD_Top:near	; First byte address after $UPD-engine

Generations_Cnt	equ	20	; 20 generations (not above 255)
Crypt_Length	equ	EndOfCrypt-Offset Tiny_Proc
EOF		equ	$UPD_Top
CF		equ	0dh,0ah

Start:
	cld
	call	Display_Image	; Show our copyrights
	lea	si,Msg
	mov	ah,02
	call	Show_String

	xor	cx,cx
	mov	cl,Generations_Cnt

Creet_Next:
	push	cx

	lea	dx,File_Name	; Make encrypted file
	mov	ah,3ch
	xor	cx,cx
	int	21h
	xchg	ax,bx

	push	bx
	lea	si,Tiny_Proc	; ds:[si]=coding data
	lea	di,EOF		; es:[di]=buffer for encoded data
	mov	ah,00001111b	; Use int 21h generations, disable IRQ 1,3,4
	lea	bx,Calc_Ofs	; Ask $UPD decoder to return bx in stack
	mov	dx,0202h	; and dx in kbd buffer (Offset Calc_Ofs & 0200h)
	mov	cx,Crypt_Length	; cx=coding data length
	call	$UPD		; Make polymorphic copy of Tiny_Prog
	pop	bx

	mov	ah,40h		; cx=size of encoded date
	lea	dx,EOF
	int	21h

	mov	ah,3eh		; Close file
	int	21h

	lea	si,[File_Name+5] ; File number
	call	Increase_Char
	lea	si,[Number]
	call	Increase_Char

	pop	cx
	loop	Creet_Next

	int	20h

File_Name	db	'test_00h.com',0
Msg		db	'Generating 20 polymorph-encrypted simply programs, '
		db	'please wait ...'
		db	CF,0

; Procedure increace symbol number (byte) at ds:[si]

Increase_Char	proc	near

	lodsw
	call	IncreaseByte
	cmp	ah,'0'
	jne	No_Overflow

	xchg	ah,al
	call	IncreaseByte
	xchg	ah,al

No_Overflow:
	mov	word ptr [si-2],ax

	retn

Increase_Char	endp

; Procedure increase string number 'x' on 1 byte
; Entry: ah=_STRING_ number
; Return: ah='0' if overflow

IncreaseByte	proc	near

	cmp	ah,'9'
	jb	Increase
	je	Last_Number
	cmp	ah,'F'
	jb	Increase
	mov	ah,'0'
	retn

Last_Number:
	mov	ah,'@'
Increase:
	inc	ah
	retn

IncreaseByte	endp

; Coding routine. Here you can put virii copy, for example ;)

Tiny_Proc	proc	near

	cld
	call	$+3
Calc_Ofs:
	pop	bx si		; si equ Offset Calc_Ofs
	sub	bx,si

	call	Display_Image

	lea	si,[bx+Demo_Hi_Msg]

	xor	ax,ax		; Read to ax value 0200h from keyboard buffer
	int	16h
	mov	bl,al
	xor	ax,ax
	int	16h
	mov	bh,al
	xchg	bx,ax

	call	Show_String

	mov	dl,7		; Generate beep
	int	21h

	in	al,21h		; Enable IRQ 1,3,4
	and	al,0e5h
	out	21h,al

	retn			; DOS exit

Demo_Hi_Msg	db	'This is simply program number '
Number		db	'00'
		db	'h, which was generated with [$UPDû2.2] demo',CF,0

Tiny_Proc	endp

include	c00l.inc

; Procedure shows ASCIIZ-string at ds:[si]
; Return: ax,dx,si=?

Show_String	proc	near

; $UPD must return 0200h in kbd buffer. But it function "Display char" ;)
; So, this tiny program will not work without decryptor!!!

Repeat_Show_String:
	lodsb
	test	al,al
	jz	EOS
	mov	dl,al
	int	21h
	jmp	Repeat_Show_String

EOS:
	retn

Show_String	endp

EndOfCrypt	=	$

	end	Start
