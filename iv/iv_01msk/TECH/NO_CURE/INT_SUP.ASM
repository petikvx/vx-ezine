;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³INFECTED MOSCOW ³#1³ JAN'97 ³(C)STEALTH Group MoscoW & Co ³ one@redline.ru~ ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ ¡à ¡®âç¨ª INT 06 ¤«ï ­¥¨§«¥ç¨¬®£® ä ©«         ³(C) Stainless Steel Rat ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		jumps
		.386p
cseg		segment para use16
		assume	cs:cseg,ds:cseg
		org	100h
start:
		mov ax,2506h
		mov dx,offset inter
		int 21h
		mov ax,3100h
		int 21h
inter:
		pop word ptr cs:[offset __ip]
		pop word ptr cs:[offset __cs]
		push word ptr cs:[offset __cs]
		push word ptr cs:[offset __ip]


		push es ax di bp
		mov ax,word ptr cs:[offset __cs]
		mov es,ax
		mov di,word ptr cs:[offset __ip]
		
		mov ax,word ptr es:[di+2]
		mov word ptr es:[di+1],ax
		mov byte ptr es:[di],0B8h
		mov word ptr es:[di+3],21CDh
		jmp exit

exit:
		pop bp di ax es
		iret

__ip		dw 0
__cs		dw 0



cseg		ends
                end  start