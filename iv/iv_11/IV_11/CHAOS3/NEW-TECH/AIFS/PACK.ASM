; (c) Reminder  (1997)

.model tiny
.code
.startup

;------------------ cicl 1  ---
lea si,_table
lea di,buf
mov cx,100h/2
@c1:
lodsw
push cx
mov cl,4
shl ah,cl
pop cx
or al,ah
stosb
loop @c1
;------------------ cicl  2 ----
lea si,buf
mov cx,100h/2
mov di,buf1
xor dx,dx

@c2:
inc bx
lodsb
cmp bx,0fh
jae @yes

cmp al,dl
jz @ok
cmp bx,3
jb @not
@yes:
push ax
mov al,70h
or al,bl
sub di,bx
stosb
mov al,dl
stosb
pop ax

@not:
xor bx,bx

@ok:
stosb
mov dl,al
loop @c2

mov bp,di
sub bp,offset buf1

mov ah,3ch
lea dx,fname
mov cx,20h
int 21h

xchg ax,bx

mov ah,40h
mov dx,offset buf1
mov cx,bp
int 21h
ret
include table.inc
fname db 'tab.new',0
buf:
len equ  100h/2
buf1 equ offset buf+len

end
