; (c) Reminder (1996)

out_word:
push ax ax
xchg al,ah
call out_byte
pop ax
call out_byte
pop ax
ret

out_byte:
push ax
push cx
mov cx,4
shr al,cl
pop cx
call out_part
pop ax
and al,0fh

out_part:
add al,30h
cmp al,'9'
jbe next
add al,7
next:

out_char:
push ax dx
mov dl,al
mov ah,2
int 21h
pop dx ax
;int 29h
ret
