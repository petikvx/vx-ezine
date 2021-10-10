; (c) Reminder 1996
; Hook interupts 	

push es		; mcb
pop ds	

mov ax,3521h
int 21h
mov word ptr ds:[old],bx
mov word ptr ds:[old+2],es

mov ax,2521h
mov dx,offset rez_part
int 21h
