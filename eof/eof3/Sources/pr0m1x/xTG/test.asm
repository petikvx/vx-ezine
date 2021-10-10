;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;										  																 ;
;										  ���� ������� 													 ;
;										RANG32, xTG, FAKA												 ;
;						(rang32.asm, faka.asm, xtg.inc, xtg.asm, logic.asm)								 ; 
;																										 ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;

																		;m1x
																		;pr0mix@mail.ru
																		;EOF 

.386
.model flat, stdcall
option casemap:none

include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib





.data
rdata_buf					db		1000h	dup	(00)
rd_size						equ		$ - rdata_buf - 1
xdata_buf					db		1000h	dup	(00)
xd_size						equ		$ - xdata_buf - 1
xtg_trash_gen_buf			db		1000h	dup	(00)					;����� ��� ࠧ���� �㦤�; 
faka_fakeapi_gen_buf		db		1000h	dup	(00) 
xtg_func_struct_buf			db		1000h	dup	(00)
trash_code_buf				db		5000h	dup	(00)
tcb_size					equ		$ - trash_code_buf - 0C4Eh
xtg_data_struct_buf			db		1000h	dup	(00)

path_buf					db		1000h	dup	(00)
pb_size						equ		$ - path_buf - 1

szMsg						db	'test engines OK!', 0





.code

engines:
include		rang32.asm													;������祭�� �������
include		xtg.inc	
include		xtg.asm
include		faka.asm
include		logic.asm



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� xVirtualAlloc
;�㭪� �뤥����� �����;
;���� (stdcall: (DWORD xVirtualAlloc(DWORD xsize))):
;	xsize	-	᪮�쪮 ���� �㦭� �뤥����;
;�����:
;	(+)		-	�뤥������ ������;
;	EAX		-	���� �뤥������ �����; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xVirtualAlloc:
	pushad
	mov		eax, dword ptr [esp + 24h]
	
	push	PAGE_EXECUTE_READWRITE
	push	MEM_RESERVE + MEM_COMMIT
	push	eax
	push	0
	call	VirtualAlloc
	
	mov		dword ptr [esp + 1Ch], eax
	popad
	ret		04
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� xVirtualAlloc; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�㭪� xVirtualFree
;�᢮�������� (࠭�� �뤥������) �����
;���� (stdcall: (DWORD/VOID xVirtualFree(DWORD xaddr))):
;	xaddr	-	���� �����, ������ �㦭� �᢮������
;�����:
;	(+)		-	������ �᢮�������, �� ᯠᥭ� =)
;	
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx	
xVirtualFree:
	pushad
	mov		eax, dword ptr [esp + 24h]
	
	push	MEM_RELEASE
	push	0
	push	eax
	call	VirtualFree
	
	popad
	ret		04
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;����� �㭪� xVirtualFree 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;�������!
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xstart:
	push	0
	call	GetModuleHandleA											;����砥� ������ ���� ����㧪� (⠪�� ����� �१ fs etc); 

	push	pb_size
	push	offset path_buf
	push	eax
	call	GetModuleFileNameA											;����砥� ��� �⮣� 䠩��
	
	push	0 
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	0
	push	FILE_SHARE_READ + FILE_SHARE_WRITE
	push	GENERIC_READ
	push	offset path_buf
	call	CreateFileA													;���뢠�� �� �⥭�� ��� 䠩���

	;inc	eax															;�� �㤥� ������ ����� ࠧ��� �஢�ப; 
	;je		__
	;dec	eax

	push	eax
	xor		ebx, ebx 
	
	push	ebx
	push	ebx
	push	ebx
	push	PAGE_READONLY
	push	ebx
	push	eax
	call	CreateFileMapping											;ᮧ��� �஥��� 䠩��

	push	eax

	push	ebx
	push	ebx
	push	ebx
	push	FILE_MAP_READ
	push	eax
	call	MapViewOfFile												;�஥��㥬

	push	eax
	xchg	eax, edi													;� edi ⥯��� ���� ������ 䠩��; 
;-----------------------------------------------------------------------;᭠砫� �஢�ਬ ᮢ������ ࠡ��� ������� RANG32 + xTG + FAKA																		
	lea		eax, xtg_trash_gen_buf
	xchg	eax, ecx
	assume	ecx: ptr XTG_TRASH_GEN										;� ���� ��������� �������� XTG_TRASH_GEN
	mov		[ecx].fmode, XTG_REALISTIC									;०�� ॠ����筮���
	mov		[ecx].rang_addr, RANG32										;���� ���
	mov		[ecx].faka_addr, FAKA										;���� ������ �����樨 ������ ������襪
	lea		ebx, faka_fakeapi_gen_buf
	mov		[ecx].faka_struct_addr, ebx									;��।���� ���� ���饩 �������� ��� ������ FAKA; 
	;lea	eax, xtg_func_struct_buf
	mov		[ecx].xfunc_struct_addr, 0 ;eax								;����� ��� 0 - ⠪ ��� ������ �㤥� ᠬ �����஢��� �㭪� (� �஫�����, ������� � �.�.); 
	mov		[ecx].alloc_addr, xVirtualAlloc								;���� �㭪� �뤥����� �����
	mov		[ecx].free_addr, xVirtualFree								;���� �㭪� �᢮�������� �����
	lea		eax, trash_code_buf 
	mov		[ecx].tw_trash_addr, eax									;� �㤥� �����஢��� ����� �������
	mov		[ecx].trash_size, tcb_size									;ࠧ��� �⮣� ����
	mov		[ecx].xmask1, (XTG_FUNC + XTG_REALISTIC_WINAPI + XTG_LOGIC)	;㪠�뢠��, �� �㤥� �����஢��� �㭪� � ������誨, � ⠪�� �� ���� �㤥� ������ (� ०��� "ॠ���⨪"); 
	mov		[ecx].xmask2, 0												; 
	mov		[ecx].fregs, 0 												;�� ॣ� ����� ���� �ᯮ�짮���� �� �����樨 ������ (�� �஬� ��������� ��� ����⠭������� esp � ebp); 
	lea		edx, xtg_data_struct_buf
	mov		[ecx].xdata_struct_addr, edx								;���� ���饩 �������� XTG_DATA_STRUCT; 
																		;⠪, �������� XTG_TRASH_GEN ���������, ���堫� �����
	assume	edx: ptr XTG_DATA_STRUCT									;�������� ⥯��� XTG_DATA_STRUCT; 
	mov		[edx].xmask, XTG_DG_ON_XMASK								;㪠�뢠��, �� �㤥� ������� ��� � ����-����: ��ப� � �᫠; 
	lea		eax, rdata_buf
	mov		[edx].rdata_addr, eax										;����, �㤠 ���� ����ᠭ� ����-�����
	mov		[edx].rdata_size, rd_size									;ࠧ��� �⮣� ����
	mov		[edx].rdata_pva, XTG_VIRTUAL_ADDR							;㪠�뢠�, �� � rdata_addr ���� ��।�� ����㠫�� (� �� 䨧��᪨�); 
	lea		eax, xdata_buf	
	mov		[edx].xdata_addr, eax										;� ���� � �⮩ ������ ����� ���� �ਬ������� ������묨 ᣥ���஢���묨 ���������, ���ਬ��, ��� ⠪��: inc dword ptr [403008h] -> 403008h - ����� ���� ���ᮬ � ������ ������ �����; 
	mov		[edx].xdata_size, xd_size									;ࠧ��� ������ ������ �����;

	assume	ebx: ptr FAKA_FAKEAPI_GEN									;⠪, ⥯��� �������� �������� FAKA_FAKEAPI_GEN
	mov		[ebx].mapped_addr, edi										;���� 䠩�� � ����� (aka ���� ������)
	mov		[ebx].rang_addr, RANG32										;���� ���
	mov		[ebx].alloc_addr, xVirtualAlloc								;���� �㭪� �뤥����� �����
	mov		[ebx].free_addr, xVirtualFree								;���� �㭪� �᢮�������� �����
	mov		[ebx].xfunc_struct_addr, 0									;��� �⠢�� 0, ⠪ ��� FAKA ᥩ�� �㤥� �ᯮ�짮������ � ������ xTG - � xTG �㤥� ᠬ ������� �㭪� (� �஫����� etc) (䫠� XTG_FUNC); 
	mov		[ebx].tw_api_addr, 0 										;��� ⮦� �⠢�� 0, ⠪ ��� FAKA ᥩ�� �㤥� ���� � ������ xTG, ����� ᠬ �������� ������ ���� �㦭� ���祭��� (�� ���� �筮 �� �����, ��� ������ �㤥� ᣥ���஢��� ���誠=)); 
	mov		[ebx].api_size, 0 											;etc
	mov		[ebx].xdata_struct_addr, edx								;㪠�뢠�� ���� �� �� �� ��������, �� � � �������筮� ���� �������� XTG_TRASH_GEN - �� ⮩ �� ��稭� - FAKA & xTG ࠡ���� ᥩ�� �����; 
	mov		[ebx].api_hash, 0											;�㤥� ������� ������誨 �� ��࠭�� �����⮢������� ����� � FAKA (⠡��� ��襩); 
 
	push	ecx 
	call	xTG															;��뢠�� ����� xTG
 
	pushad																;��࠭�� ⥪�騥 ���祭�� ��� ॣ�� � �⥪�; 
	mov		eax, [ecx].nobw												;���-�� ॠ�쭮 ����ᠭ��� ����; 
	mov		eax, [ecx].fnw_addr											;eax = ���� ��� ���쭥�襩 ����� ���� (�� ��室� �� xTG �� ࠢ�� �⮬� �� ���祭�� - ���� �஢��塞 ������ ����); 
	;mov	byte ptr [eax], 0C3h
	call	[ecx].ep_trash_addr											;�窠 �室� � ����: ᥩ�� �㤥� �믮������� ⮫쪮 �� ᣥ���஢���� ����-���; 
	popad																;����⠭����; 
;-----------------------------------------------------------------------;⥯��� �஢�ਬ ࠡ��� RANG32 + xTG
	mov		[ecx].fmode, XTG_MASK										;⥯��� ������� ०�� "��᪠"
	mov		[ecx].faka_addr, 0											;�⪫�砥� FAKA; 
	mov		[ecx].faka_struct_addr, 0									;
	mov		[ecx].xmask1, XTG_MOV_XCHG___R32__R32						;㪠�뢠��, ����� ������� �㤥� ������� � �⮬ ०���;
	add		[ecx].xmask1, (XTG_MOV_R32_R16__IMM32_IMM16 + XTG_ADC_ADD_AND_OR_SBB_SUB_XOR___R32_R16__R32_R16)
	mov		[ecx].xmask2, XTG_ADC_ADD_AND_OR_SBB_SUB_XOR___M32_M8__IMM32_IMM8
	mov		[ecx].fregs, (XTG_ECX + XTG_EDI) 							;ecx � edi ��᫥ �믮������ ᣥ���஢������ ����-���� �� ������� ᢮�� ���祭�� (⠪ ��� �� �� � ���㡨�� ������� ������襪); 
																		
	mov		[edx].xmask, XTG_DG_STRA									;㪠�뢠��, �� �㤥� ������� ��� � ����-���� - �� ��� ࠧ ⮫쪮 ��ப�; 
	
	push	ecx
	call	xTG															;᭮�� ��뢠�� ����� xTG; 

	pushad
	mov		eax, [ecx].nobw												;���-�� ॠ�쭮 ����ᠭ��� ����; 
	mov		eax, [ecx].fnw_addr											;eax = ���� ��� ���쭥�襩 ����� ���� (�� ��室� �� xTG �� ࠢ�� �⮬� �� ���祭�� - ���� �஢��塞 ������ ����); 
	mov		byte ptr [eax], 0C3h										;⠪ ��� �� ����ਫ� ������� �������, � � ���� ����-���� ���⠢�� ret - �⮡� ᭮�� ��३� �� ��� �������; 
	call	[ecx].ep_trash_addr											;�窠 �室� � ����: ᥩ�� �㤥� �믮������� ⮫쪮 �� ᣥ���஢���� ����-���; 
	popad
;-----------------------------------------------------------------------;⥯��� �஢�ਬ RANG32 + FAKA; 
	mov		[ebx].mapped_addr, edi										;���� 䠩�� � ����� (aka ���� ������)
	mov		[ebx].rang_addr, RANG32										;���� ���
	mov		[ebx].alloc_addr, xVirtualAlloc								;���� �㭪� �뤥����� �����
	mov		[ebx].free_addr, xVirtualFree								;���� �㭪� �᢮�������� �����
	mov		[ebx].xfunc_struct_addr, 0									;��� �⠢�� 0, ⠪ ��� �� ����ਬ ᥩ�� �㭪� (� �஫����� etc); 
	lea		eax, trash_code_buf
	mov		[ebx].tw_api_addr, eax 										;���� ����, �㤠 ᣥ��ਬ ��-���; 
	mov		[ebx].api_size, tcb_size  									;ࠧ��� �⮣� ���� (��� ����� ���⠢���, ���ਬ��, WINAPI_MAX_SIZE); 
	mov		[ebx].xdata_struct_addr, edx								;㪠�뢠�� ���� �� ����������� �������� XTG_DATA_STRUCT; 
	mov		[ebx].api_hash, 0B1866570h									;�㤥� ������� �����⭮ GetModuleHandleA; 

	push	ebx
	call	FAKA														;��뢠�� FAKA'�; 

	pushad
	mov		eax, [ebx].fnw_addr
	mov		byte ptr [eax], 0C3h
	call	[ebx].tw_api_addr											;�믮���� ⮫쪮 �� ᣥ��७�� �맮� ������誨; 
	popad

;-----------------------------------------------------------------------;⥯��� �஢�ਬ ⮫쪮 RANG32

	push	05
	call	RANG32														;��� � ���;

;-----------------------------------------------------------------------; 	
	call	UnmapViewOfFile 
	call	CloseHandle
	call	CloseHandle
 
	xor		eax, eax
	lea		ecx, szMsg
	
	push	eax
	push	ecx 
	push	ecx
	push	eax
	call	MessageBoxA 

	jmp		_xtest_ret_



;comment !
	call	QueryPerformanceCounter
	call	QueryPerformanceFrequency
	call	lstrcmpiA
	call	lstrcmpA
	call	lstrcpyA
	call	lstrlenA
	call	GetSystemTime
	call	GetLocalTime
	call	GetVersion; 
	call	GetOEMCP; 
	call	GetCurrentThreadId
	call	GetCurrentProcess
	call	GetTickCount
	call	GetCurrentProcessId
	call	GetProcessHeap
	call	GetACP
	call	GetCommandLineA
	call	GetCurrentThread
	call	IsDebuggerPresent
	call	GetThreadLocale
	call	GetCommandLineW
	call	GetSystemDefaultLangID
	call	GetSystemDefaultLCID
	call	GetUserDefaultUILanguage
	call	Sleep
	call	MulDiv
	call	IsValidCodePage
	call	GetDriveTypeA
	call	IsValidLocale
	call	GetModuleHandleA
	call	LoadLibraryA
	call	GetProcAddress

	call	GetFocus
	call	GetDesktopWindow
	call	GetCursor
	call	GetActiveWindow
	call	GetForegroundWindow
	call	GetCapture
	call	GetMessagePos
	call	GetMessageTime
	call	GetDlgItem
	call	GetParent
	call	GetSystemMetrics
	call	GetWindow
	call	IsDlgButtonChecked
	call	IsWindowVisible
	call	IsIconic
	call	IsWindowEnabled
	call	CheckDlgButton
	call	GetSysColor
	call	GetKeyState
	call	GetDlgCtrlID
	call	GetSysColorBrush
	call	SetActiveWindow
	call	IsChild
	call	GetTopWindow
	call	GetKeyboardType
	call	GetKeyboardLayout
	call	IsZoomed
	call	GetWindowTextLengthA
	call	DrawIcon
	call	GetClientRect
	call	GetWindowRect
	call	CharNextA
	call	GetCursorPos
	call	LoadIconA
	call	LoadCursorA
	call	FindWindowA

	call	SelectObject
	call	SetTextColor
	call	SetBkColor
	call	SetBkMode
	call	Rectangle
	call	GetTextColor
	call	GetBkColor
	call	SetROP2
	call	GetCurrentObject
	call	Ellipse
	call	GetNearestColor
	call	GetObjectType
	call	PtVisible
	call	GetMapMode
	call	GetBkMode
		;!

_xtest_ret_:
	ret
end xstart
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;VX! 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



 


 