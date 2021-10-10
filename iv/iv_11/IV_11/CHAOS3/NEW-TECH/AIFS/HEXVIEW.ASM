; (c) Reminder  (1997)

.model tiny
.code
.startup

mov si,81h
mov di,offset fname
xor bx,bx
cld
@123:
lodsb
cmp al,20h
jbe @again
stosb
@again:
cmp al,0dh
jnz @123
xor ax,ax
stosb

mov ax,3d00h
lea dx,fname
int 21h
jc er
xchg ax,bx
mov ah,3fh
mov cx,256
lea dx,buf
int 21h
jc er

cld
lea si,buf
mov cx,ax
xor bp,bp

mov ah,9
lea dx,mess
int 21h


mov al,'d'
call out_char
mov al,'b'
call out_char
mov al,' '
call out_char

@1:
lodsb
push ax
mov al,'0'
call out_char
pop ax
call out_byte
mov al,'h';
call out_char
inc bp
cmp bp,10
ja @3
cmp cl,1
jz @3

mov al,','
call out_char
jmp @2

@3:
xor bp,bp
mov al,0dh
call out_char
mov al,0ah
call out_char
cmp cl,1
jz @2

mov al,'d'
call out_char
mov al,'b'
call out_char
mov  al,' '
call out_char


@2:
loop @1

ret

er:
mov al,7
int 29h

mov ah,9
lea dx,help
int 21h

ret

include hex.inc

mess db ';This file was created using Hex-view (c) 1997 by Reminder',0dh,0ah,'$'
help db 'Usage: Hexview file$'
fname db 'xxxxxxxx.xxx',0
buf:

end

