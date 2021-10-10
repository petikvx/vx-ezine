;
;	Рекурсивный поиск файлов.
;	(c) Ak Kort [SOS group]
;	Microsoft Assembler 6.0
;
	.model tiny
	.486
	.code
	.startup
	org 100h
	jmp beg
	
msk	db '*.exe',0	; Какие файлы искать.
pth	db '\',0	; Где искать.
dsk	db 3		; на каком диске (сейчас - С)
all	db '*.*',0	; Чтобы входить во все подкаталоги
old	db '..',0	; предыдущий каталог
oldpath	db 64 dup (0)	; старый каталог
curpath db 64 dup (0)	; текущий каталог

beg:
	mov ah,19h
	int 21h
	mov ah,0Eh
	push ax
	mov dl,dsk
	int 21h
	mov ah,47h
	cwd
	lea si,oldpath
	push si
	int 21h
	lea dx,pth
	call Recurse
	pop dx
	mov ah,3Bh
	int 21h
	pop ax
	mov dl,al
	int 21h
	retn
		
Recurse:
	mov ah,3Bh	; переходим в новый каталог
	int 21h
	sub sp,44	; создаем локальную DTA
	mov dx,sp	; всего может быть не более 31 подкаталога => всего
	mov si,dx	; может потребоваться (44+4)*31=1488 байт стека
	add si,1Eh	; не так уж и много
	mov ah,1Ah
	int 21h
	lea dx,msk	; поиск файлов
	xor cx,cx
	mov ah,4Eh
	int 21h
	jc @1
@2:	call PrintName	; нашли!
	mov ah,4Fh
	int 21h
	jnc @2
@1:
	mov cx,16	; поиск всех каталогов
	lea dx,all
	mov ah,4Eh
	int 21h
	jc @3
@5:	
	test byte ptr [si-9],16	; подлая ms-dos вместе с каталогами выдает
				; и файлы - будем отсекать
	jz @4
	cmp word ptr [si],'.'		; корневая директория
	jz @4
	cmp word ptr [si],'..'		; надкаталог
	jz @4
	
	push si
	mov dx,si
	call Recurse	; рекурсивный вызов
	lea dx,old	; выодим из подкаталога
	mov ah,3Bh
	int 21h
	pop si
	lea dx,[si-1Eh]	; назначаем старую dta
	mov ah,1Ah
	int 21h
@4:
	mov ah,4Fh
	int 21h
	jnc @5
@3:
	add sp,44	; удалаяем локальную dta
	retn

PrintName:
	push si
	mov al,dsk
	add al,'A'
	int 29h		; int 29h - fast put char
	mov al,':'
	int 29h
	mov al,'\'
	int 29h
	lea dx,curpath
	mov ah,47h
	mov si,dx
	cwd
	int 21h
	call PrintStr
	mov al,'\'	; для файлов в корневухе напечатается два слеша,
	int 29h		; что в принципе не страшно
	pop si
	call PrintStr
	mov al,13
	int 29h
	mov al,10
	int 29h
	retn
	
PrintStr:
	push si
@6:	lodsb
	or al,al
	jz @7
	int 29h
	jmp @6
@7:	
	pop si
	retn

end

