;Example how to make cool effects on CGA & 8086/8088 CPU
;		(C) 1996 J/SOFT

	org 100h
	mov ax,6
	int 10h		;init CGA 640x200 graphcs mode

	mov al,5	;rerandomize random number generator.
	mov [r1],al
	mov al,90
	mov [r2],al
	mov al,37
	mov [r3],al

	mov ax,0b800h
	mov es,ax
	xor di,di
	mov cx,16384
rrr	call rnd
	es:
	mov [di],al
	inc di
	loop rrr

	xor al,al
	mov [step],al
	mov [tim],al
	mov [adr_h],al
	mov [adr_l],al
	inc al
	mov [step_p],al

main	call halt
	mov ah,1
	int 16h
	jz main2
	xor ah,ah
	int 16h
	cmp al,27
	jnz main2

	mov ax,3
	int 10h
	mov ax,cs
	mov ds,ax
	mov dx,offset endtxt
	mov ah,9
	int 21h
	mov ax,4c00h
	int 21h
endtxt	db '		This nice scroll for XT is copyright (C) 1996 J/SOFT',13,10,10
	db '				* GOODBYE *$'

main2	mov al,[tim]
	inc al
	and al,3
	mov [tim],al
	jnz cnt1
	call a_d_d
cnt1	mov al,[adr_h]
	mov bh,al
	mov bl,[adr_l]
	mov al,[step]
	mov ah,40
	imul ah	
	add ax,bx
	mov [adr_l],al
	mov al,ah
	mov [adr_h],al
	
	call port

	jmp main

tim	db 0
r1	db 0
r2	db 0
r3	db 0
adr_h	db 0
adr_l	db 0
step	db 0
step_p	db 1

port	mov dx,3d4h
	mov al,0ch
	out dx,al
	inc dx
	mov al,[adr_h]
	out dx,al
	dec dx
	mov al,0dh
	out dx,al
	inc dx
	mov al,[adr_l]
	out dx,al
	retn

rnd	mov al,[r1]
	mov ah,al
	mov al,[r2]
	mov [r1],al
	add ah,al
	mov al,[r3]
	mov [r2],al
	add al,ah
	rol al
	mov [r3],al
	retn

halt	mov dx,3dah
vrt	in al,dx
	test al,8
	jnz vrt
novrt	in al,dx
	test al,8
	jz novrt
	retn

a_d_d	mov al,[step]
	add al,[step_p]
	mov [step],al
	cmp al,8
	jz inv
	cmp al,-8
	jz inv
	
i_cont	retn

inv	mov al,[step_p]
	not al
	inc al
	mov [step_p],al
	jmp i_cont