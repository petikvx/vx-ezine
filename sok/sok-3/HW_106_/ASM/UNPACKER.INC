Unpacker:
	mov bx,es
	add bx,16
	push es
	mov es,bx
	mov dx,bx
	push cs
	pop ds
	lea si,relocs-unpacker
	xor di,di
	mov cl,4
@u5:	xor ax,ax
	lodsb
	or al,al
	jnz @u1
	lodsb
	push ax
	lodsw
	shl ax,cl
	add dx,ax
	pop ax
@u1:	
	add di,ax
	mov ax,di
	and di,15
	shr ax,cl
	add dx,ax
	mov es,dx
	add es:[di],bx
@u3:	cmp si,12345
un_all	equ word ptr [$-2]
	jc @u5
	pop es
	push es
	pop ds
	cli
un_sp	equ word ptr [$+1]
	mov sp,12345
un_ss	equ word ptr [$+1]
	mov ax,12345
	add ax,bx
	mov ss,ax
	sti	
	add bx,12345
un_cs	equ word ptr [$-2]
	push bx
un_ip	equ word ptr [$+1]
	mov ax,12345
	push ax
	retf
relocs:	
