;Program by CyberShadow...
;creating date 24.07.97
;Резидент может занимать в памяти очень мало места.

.model tiny
.code
.386
org 100h
mystart:
        jmp short myinit
new_21:
	push es ax
	mov ax,0b800h
	mov es,ax
	mov word ptr es:[0],'SC'
	mov word ptr es:[2],'SS'
	pop ax es
	db 0eah
old_21	dd 0
myinit:
        mov ax,03521h
        int 21h
        mov word ptr [old_21],bx
        mov word ptr [old_21+2],es
	mov es,cs:[2ch]
        mov ah,49h
        int 21h
	push cs
	pop es
	mov si,100h+2
	mov di,40h
	mov cx,offset myinit-offset new_21
	rep movsb
        mov dx,40h
        mov ax,02521h
        int 21h
	mov dx,40h+offset myinit-offset new_21
	int 27h
end mystart
