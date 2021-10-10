;Всегда полезно уметь запускать одну программу из другой (спутники всякие)!

.model tiny
.code
	org 100h
start:
	mov ax,cs
	mov ds,ax
	mov es,ax
	push ds es
	mov ax,4a00h
	mov bx,1000h
	int 21h
	pop es ds
	mov dx,offset start_l
	mov bx,offset block_s
	mov word ptr cs:[bx],0
	mov word ptr cs:[bx+2],offset lkj
	mov cs:[bx+4],cs
	mov cs:tmp_1,ss
	mov cs:tmp_2,sp
	mov ax,4b00h
	int 21h
	cli
	mov ss,cs:[tmp_1]
	mov sp,cs:[tmp_2]
	sti
	mov ah,4ch
	int 21h
tmp_1	dw 0
tmp_2	dw 0
start_l db 'C:\COMMAND.COM',0
lkj	db 255,'/c '
	db 'disk:\path\filename.ext command line'
	db 0dh
block_s dw 0,0,0
end start
