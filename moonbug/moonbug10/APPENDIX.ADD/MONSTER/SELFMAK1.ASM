;Self Source Maker - part I - by FRiZER
.model tiny
.code
.286
.startup
org 256
s:
mov ah,9
lea dx,o1
int 21h

cld
mov cx,e-s
lea si,s
xor bx,bx
l0:
mov ah,9
lea dx,o2               ; 'db 0$'
int 21h
jmp l2
l1:
mov ah,9                ; ', 0$'
lea dx,o3
int 21h
l2:
inc bx
lodsb
dec si
shr al,4
call pc
lodsb
and al,0Fh
call pc

mov ah,2
mov dl,'h'
int 21h

test bx,07h
jz l3
loop l1
jmp l4
l3:
mov ah,2
mov dl,13
int 21h
mov dl,10
int 21h
loop l0
l4:
mov ah,9
lea dx,o4
int 21h

ret

pc:
add al,'0'
cmp al,'9'
jbe lx
add al,7
lx:
xchg ax,dx
mov ah,2
int 21h
ret
o1      db '.model tiny',13,10
        db '.code',13,10
        db '.286',13,10
        db '.startup',13,10
        db 'org 256',13,10
        db 's:',13,10,'$'
o2      db 'db 0$'
o3      db ', 0$'
o4      db 13,10
        db 'e:',13,10
        db 'end$'

e:
end
