; "Asm Instruction First byte Show" (Small disasm) (c) Reminder (1997)

@dis_init:	; di - buf for table (256) 

lea si,rle_table
mov cx,88
cld
@c1:
lodsb
mov bx,1
push ax
and al,0F0h
cmp al,70h
pop ax
jnz @s1
and al,0fh
mov bl,al
lodsb
dec cx

@s1:
push ax cx ax
and al,0fh
stosb
pop ax
mov cx,4
shr al,cl
stosb
pop cx ax
dec bx
jnz @s1
loop @c1
ret

include tab.inc

; Table 4 "Asm Instruction First byte Show" (Small disasm) (c) Reminder (1997)

;  11111111b
;  |   |
;  |   |
;  |   -  @1 (field 0 - 3 bit)			@1 - first byte
;  -  @2 (field 4-7 bit)			@2 - second  byte

; RLE Compression ;)
;if @2 = 0111b then next byte*@1






; (c) Reminder  (1997)

;	bp - ofsfet table si - kod.		si - next kod
@dmain:
push bx
lodsb
		;----------
		cmp al,0fh
		jz sux
		cmp al,0f1h
		jz sux
		;----------
mov bx,bp
xlat
xor bx,bx

or al,al
jz quit
push ax		; imm
and al,7
add bl,al
pop ax

test al,8		;rm
jz quit
lodsb
mov ah,al
push cx
mov cl,6
shr al,cl
pop cx
cmp al,3
jz quit
add bl,al
or al,al
jnz quit
and ah,7
cmp ah,6
jnz quit
add bx,2
quit:
add si,bx
clc
pop bx
ret

sux:
stc
pop bx
ret
