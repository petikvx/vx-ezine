; (c) Reminder  (1997)

.model tiny
.code
.startup

number equ 31

;--------------- get 1 param (fname)
mov si,81h
lea di,fname
@para1:
lodsb
cmp al,20h
jbe @para2
stosb
@para2:
cmp al,0dh
jnz @para1
xor ax,ax
stosb
;---------------

cld
mov ax,3d00h
lea dx,fname
int 21h
jc er
xchg ax,bx
mov ah,3fh
lea dx,buf
mov cx,0f000h
int 21h
jc er

lea di,sot
call @dis_init

lea si,buf
mov cx,number
lea bp,sot

@vb:
lodsb
dec si

push ax
call out_byte
mov al,' '
call out_char
pop ax

cmp al,0e9h
jnz @n1
lodsb
lodsw
add si,ax
jmp @vb
@n1:

cmp al,0ebh
jnz @n2
lodsb
lodsb
mov dx,si
add dl,al
mov si,dx
jmp @vb
@n2:

call @dmain
jc er
loop @vb

sub si,offset buf
mov ax,si
call out_word

ret

er:
mov al,7
int 29h
ret

include aifs.inc
include hex.inc

fname 	db 13 dup (?)
sot 	db 260 dup (?)
buf:

end
